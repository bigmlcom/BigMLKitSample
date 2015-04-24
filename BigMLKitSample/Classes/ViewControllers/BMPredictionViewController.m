// Copyright 2014-2015 BigML
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

#import "MMDrawerBarButtonItem.h"
#import "BMPredictionHeaderView.h"

#import "UIViewController+MMDrawerController.h"

#import "BMPredictionViewController.h"
#import "BMPredictionFieldValues.h"
#import "BMPredictionCells.h"
#import "BMPredictionForm.h"

#import "BMToolbar.h"

#import "BML4iOS.h"
#import "BMLViewModel.h"
#import "LocalPredictiveModel.h"
#import "BMLWorkflowTaskSequence.h"
#import "BMLWorkflowTaskContext.h"

#import "BMLWorkflowView.h"

#import "BMLResource.h"
#import "BMLResourceUtils.h"

#import "MAKVONotificationCenter.h"
#import "RTLabel.h"

#include <objc/runtime.h>
#include <objc/message.h>

static void* kvoContext = &kvoContext;

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@interface BMPredictionViewController ()

@property (strong, nonatomic) UIPopoverController* masterPopoverController;

- (void)configureView;

@end

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@implementation BMPredictionViewController {
    
    NSArray* _fields;
    Class _formClass;
    NSDictionary* _model;
    UIView* _indicatorView;
    
    RTLabel* _welcomeView;
    BOOL _isRunning;
    
    NSDictionary* _predictModel;
    NSDictionary* _targetField;
    NSDictionary* _predictionResult;
    BMPredictionHeaderView* _predictionResultView;
}

/////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
 
    if (self = [super init]) {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    return self;
}

#pragma mark Managing the detail item
/////////////////////////////////////////////////////////////////////////////////
- (void)setDetailItem:(id)newDetailItem {
    
    if (_detailItem != newDetailItem) {
        
        _detailItem = newDetailItem;
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

/////////////////////////////////////////////////////////////////////////////////
- (BMPredictionForm*)form {
    return (BMPredictionForm*)super.formController.form;
}

/////////////////////////////////////////////////////////////////////////////////
- (void)configureView {
    
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@ %@",
                                            [_model objectForKey:@"objective_field"],
                                            [_fields description]];
    }
}

/////////////////////////////////////////////////////////////////////////////////
- (BMToolbar*)toolbarWithButtons:(NSArray*)buttons {
    
    int fixedItemCount = 0;
    for (UIBarButtonItem* item in buttons) {
        if (item.tag == -1)
            ++fixedItemCount;
    }
    BMToolbar* customToolbar = [[BMToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0, 36 * ([buttons count] - fixedItemCount) - 4, 44)];
    customToolbar.clearsContextBeforeDrawing = YES;
    customToolbar.clipsToBounds = YES;
    [customToolbar setItems:buttons animated:NO];
    return customToolbar;
}

/////////////////////////////////////////////////////////////////////////////////
- (void)setUpNavigationBar {
 
    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigLogo"]];
    [self.navigationItem setTitleView:logo];

    MMDrawerBarButtonItem* leftDrawerButton = [[MMDrawerBarButtonItem alloc]
                                               initWithTarget:self
                                               action:@selector(leftDrawerButtonPress:)];

    NSString* backArrowString = @"\U000025C0\U0000FE0E"; //-- BLACK LEFT-POINTING TRIANGLE
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:backArrowString
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backButtonPressed)];
    
    UIBarButtonItem* negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil action:nil];
    negativeSeparator.width = -16;
    negativeSeparator.tag = -1;

    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithCustomView:[self toolbarWithButtons:@[negativeSeparator, leftDrawerButton, backItem]]];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    [BMLViewModel viewModel].target = kModelTarget;

    self.view.backgroundColor = [UIColor whiteColor];

    [self.navigationController.view.layer setCornerRadius:10.0f];

    [self.formController registerCellClass:[BMPredictionRangeCell class]
                              forClassName:NSStringFromClass([BMPredictionRange class])];
    
    [self.formController registerCellClass:[BMPredictionOptionCell class]
                              forClassName:NSStringFromClass([BMPredictionOption class])];
    
    [self.formController registerCellClass:[BMPredictionDiscreteRangeCell class]
                              forClassName:NSStringFromClass([BMPredictionDiscreteRange class])];
    
    [self setUpNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makePrediction:)
                                                 name:kBMPredictionDoPredictionNotification
                                               object:nil];
    
    if (!_isRunning) {
        
        BOOL isPad = UI_USER_INTERFACE_IDIOM();
        _welcomeView = [[RTLabel alloc] initWithFrame:self.view.bounds];
        _welcomeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _welcomeView.text = [NSString stringWithFormat:@"<font face='HelveticaNeue-Light' size=%d>" \
        @"<p></p><p>Welcome to BigML!</p>" \
        @"</font><font face='HelveticaNeue-Light' size=%d>" \
        @"<p></p><p></p><p>Use the top-right ≡ menu<br>" \
        @"to browse your resources.<br>Under Files, you will find<br>a few sample files.<br>" \
        @"</font>", isPad?54:28, isPad?32:20];
        _welcomeView.textAlignment = RTTextAlignmentCenter;
        [self.view addSubview:_welcomeView];
    }
}

/////////////////////////////////////////////////////////////////////////////////
- (void)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

/////////////////////////////////////////////////////////////////////////////////
- (BOOL)addFormField:(NSString*)fieldName type:(Class)class {
    
    NSLog(@"ADD FIELD: %@", fieldName);

    char className[256] = "";
    sprintf(className, "@\"%s\"", [NSStringFromClass(class) UTF8String]);
    
    char ivarName[256] = "";
    sprintf(ivarName, "_%s", [fieldName UTF8String]);
    
    objc_property_attribute_t type = { "T", className };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", ivarName };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };

    return class_addProperty(_formClass, [fieldName UTF8String], attrs, 3);
}

/////////////////////////////////////////////////////////////////////////////////
- (Class)classFromType:(NSString*)type {

    if ([type isEqualToString:@"string"]) {
        return [NSString class];
    } else if ([type isEqualToString:@"double"]) {
        return [NSNumber class];
    } else if ([type isEqualToString:@"iint8"]) {
        return [NSNumber class];
    } else if ([type isEqualToString:@"int16"]) {
        return [NSNumber class];
    } else if ([type isEqualToString:@"int32"]) {
        return [NSNumber class];
    } else {
        NSAssert(NO, @"Should not be here!!");
    }
    return [NSString class];
}

/////////////////////////////////////////////////////////////////////////////////
- (NSArray*)allPropertyNamesForClass:(Class)class {
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}
/*******************
 Use BigMLKit framework
 *******************/
/////////////////////////////////////////////////////////////////////////////////
- (void)setupFromModel:(BMLViewModel*)model {
    
    if (model.currentResource) {
        [self stopAnimating];
        [model createWorkflowWithConfigurator:nil connector:[BML4iOS new]];
        [self startWorkflow];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)startWorkflow {
    
    _isRunning = YES;
    [_welcomeView removeFromSuperview];

    BMLWorkflowView* workflowView =
    [[BMLWorkflowView alloc] initWithTask:[BMLViewModel viewModel].workflow
                                    viewModel:[BMLViewModel viewModel]];
    workflowView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:workflowView];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:workflowView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:workflowView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [[BMLViewModel viewModel].workflow runInContext:[BMLViewModel viewModel].context
                                        completionBlock:^(NSError* error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
     
            [workflowView removeFromSuperview];
            if ([BMLViewModel viewModel].workflow.info[kModelDefinition]) {
                [self buildPredictionForm:[BMLViewModel viewModel].workflow.info[kModelDefinition]];
            } else {
                [self buildPredictionForm:[BMLViewModel viewModel].workflow.info[kClusterDefinition]];
            }
        });
    }];
}
/*******************
 End
 *******************/

/////////////////////////////////////////////////////////////////////////////////
- (void)registerObservers {
    
    BMPredictionViewController* wself = self;
    NSArray* fields = self.form.fields;
    for (NSUInteger i = 0, N = [fields count]; i < N; ++i) {
        
        BMPredictionFieldValue* field = fields[i];
        if ([field isIncluded]) {
            
            [field addObserver:self
                       keyPath:NSStringFromSelector(@selector(currentValue))
                       options:NSKeyValueObservingOptionInitial
                         block:^(MAKVONotification* notification) {
                             [wself makePrediction:nil];
                         }];
            
            [field addObserver:self
                       keyPath:NSStringFromSelector(@selector(isIncluded))
                       options:NSKeyValueObservingOptionInitial
                         block:^(MAKVONotification* notification) {
                             [wself makePrediction:nil];
                         }];
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////
- (void)unregisterObservers {
    
    NSArray* fields = self.form.fields;
    for (NSUInteger i = 0, N = [fields count]; i < N; ++i) {
        
        BMPredictionFieldValue* field = fields[i];
        if ([field isIncluded]) {
            
            [field removeObserver:self
                       forKeyPath:NSStringFromSelector(@selector(currentValue))];
            
            [field removeObserver:self
                       forKeyPath:NSStringFromSelector(@selector(isIncluded))];
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////
- (void)buildPredictionForm:(NSDictionary*)definition {
    
    NSAssert(!_formClass, @"building prediction form when one is already there");
    
    NSDictionary* fields = [[definition valueForKeyPath:@"model"] valueForKeyPath:@"fields"];
    _predictModel = definition;
    [BMPredictionForm resetFields];

    [self.form removeObserver:self
                   forKeyPath:NSStringFromSelector(@selector(predictionTarget))
                      context:kvoContext];

    if ([[fields allValues] count] > 0) {
        
        NSString* predictionClassName = [NSString stringWithFormat:@"BMConcretePrediction%@",
                                          [BMLViewModel viewModel].currentResource.name];
        _formClass = objc_allocateClassPair([BMPredictionForm class],
                                            [predictionClassName UTF8String],
                                            0);
        if (_formClass) {

            objc_registerClassPair(_formClass);
        
            NSString* objectiveFieldKey = definition[@"objective_field"];
            for (NSDictionary* field in [fields allValues]) {
                
                if (field == fields[objectiveFieldKey]) {
                    _targetField = field;
                    continue; //-- skip objective
                }
                
                if ([field[@"optype"] isEqualToString:@"numeric"]) {

                    if ([field[@"datatype"] isEqualToString:@"double"]) {
                        [self addFormField:field[@"name"] type:[BMPredictionRange class]];
                    } else {
                        [self addFormField:field[@"name"] type:[BMPredictionDiscreteRange class]];
                    }
                    [BMPredictionForm addField:
                     @{ FXFormFieldKey:field[@"name"],
                        FXFormFieldOptions:@[field[@"summary"][@"minimum"],
                                             field[@"summary"][@"maximum"]] }];
                    
                } else if ([field[@"optype"] isEqualToString:@"categorical"]) {
                  
                    NSMutableArray* categories = [NSMutableArray array];
                    for (NSArray* array in field[@"summary"][@"categories"])
                        [categories addObject:array[0]];
                    
                    [self addFormField:field[@"name"] type:[BMPredictionOption class]];
                    [BMPredictionForm addField:
                     @{FXFormFieldKey:field[@"name"],
                       FXFormFieldOptions:categories}];
                    
                } else {
                 
                    NSLog(@"UNK FIELD: %@ (%@)", field, field[@"optype"]);
                }
                
            }
            
            if (_formClass)
                self.formController.form = [_formClass new];
            else
                self.formController.form = [NSClassFromString(predictionClassName) new];
            
        } else {
            
            self.formController.form = nil;
        }
    }
    
    [self.form addObserver:self
                forKeyPath:NSStringFromSelector(@selector(predictionTarget))
                   options:0
                   context:kvoContext];

    self.formController.tableView.contentOffset = CGPointZero;
    [self.formController.tableView reloadData];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)cleanupPredictionForm {
    
    [BMPredictionForm resetFields];
    self.formController.form = nil;
    [self.formController.tableView reloadData];
    
    if (_formClass) {
        objc_disposeClassPair(_formClass);
        _formClass = nil;
    }
    [self unregisterObservers];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)startAnimating {
    
    if (!_indicatorView) {

        UIWindow* w = [UIApplication sharedApplication].keyWindow;
        _indicatorView = [[UIView alloc] initWithFrame:w.bounds];
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _indicatorView.backgroundColor = [UIColor colorWithWhite:0.75 alpha:0.5];
        _indicatorView.alpha = 0.0;
        [w addSubview:_indicatorView];
    }
    
    _indicatorView.hidden = NO;
    
    [_indicatorView.superview addSubview:_indicatorView];

    [ UIView animateWithDuration:0.33 animations:^{
        _indicatorView.alpha = 1.0;
    }];
    
}

/////////////////////////////////////////////////////////////////////////////////
- (void)stopAnimating {
    
    _indicatorView.hidden = YES;

    [ UIView animateWithDuration:0.33 animations:^{
        _indicatorView.alpha = 0.0;
    }];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {

    BMPredictionViewController* wself = self;
    BMPredictionFieldValue* field = (id)((id<FXFormFieldCell>)cell).field.value;
    
    [field removeObserver:self
                  keyPath:NSStringFromSelector(@selector(currentValue))];
    
    [field removeObserver:self
                  keyPath:NSStringFromSelector(@selector(isIncluded))];
    
    if ([field isIncluded]) {
        
        [field addObserver:self
                   keyPath:NSStringFromSelector(@selector(currentValue))
                   options:NSKeyValueObservingOptionNew
                     block:^(MAKVONotification* notification) {
                         [wself makePrediction:nil];
                     }];
        
        [field addObserver:self
                   keyPath:NSStringFromSelector(@selector(isIncluded))
                   options:NSKeyValueObservingOptionNew
                     block:^(MAKVONotification* notification) {
                         [wself makePrediction:nil];
                     }];
    }

    [(id)cell refresh];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)predictionCellHasChangedValue:(BMPredictionBaseCell*)cell {
    
}

/////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Split view
/////////////////////////////////////////////////////////////////////////////////
- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController {
    
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

/////////////////////////////////////////////////////////////////////////////////
- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Button Handlers
/////////////////////////////////////////////////////////////////////////////////
- (FXFormField*)fieldAtRow:(NSUInteger)row section:(NSUInteger)section {
    
    return [self.formController fieldForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)reloadCellAtIndexPath:(NSIndexPath*)indexPath {

    if (indexPath)
        [(id)[self.tableView cellForRowAtIndexPath:indexPath] reloadCell];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)makePrediction:(NSNotification*)sender {

    NSAssert([self.formController numberOfSections], @"No Fields found");
    NSAssert([self.formController numberOfFieldsInSection:0], @"No Fields found");
    
    [self reloadCellAtIndexPath:self.form.oldPredictionTargetIndexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableDictionary* inputDataForPrediction = [NSMutableDictionary dictionary];
        for (NSUInteger section = 0, N = [self.formController numberOfSections]; section < N; ++section)
            for (NSUInteger row = 0, M = [self.formController numberOfFieldsInSection:section]; row < M; ++row) {
                
                FXFormField* field = [self fieldAtRow:row section:section];
                if ([field.value isIncluded]) {

                    [inputDataForPrediction setObject:[field.value currentValue]?:@"" forKey:field.key?:@""];
                }
            }

        NSError* error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputDataForPrediction
                                                           options:0
                                                             error:&error];
        NSString* jsonString = nil;
        if (!jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        _predictionResult = @{@"value" : @0.0};
        if (!error) {

            _predictionResult = [LocalPredictiveModel predictWithJSONModel:@{@"model":_predictModel[@"model"],
                                                                             @"objective_field":_targetField[@"name"]}
                                                                 arguments:jsonString
                                                                argsByName:YES];
        }
        [_predictionResultView setTitle:[NSString stringWithFormat:@"%@: %@", _targetField[@"name"], _predictionResult ? _predictionResult[@"value"] : @"?"]];
        [_predictionResultView setConfidence:_predictionResult ? [_predictionResult[@"confidence"] floatValue] : 0.0/0.0];
    });
}

/////////////////////////////////////////////////////////////////////////////////
- (void)addToCurrentBatch:(id)sender {
    
}

/////////////////////////////////////////////////////////////////////////////////
- (void)leftDrawerButtonPress:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)rightDrawerButtonPress:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

/////////////////////////////////////////////////////////////////////////////////
- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    BMPredictionHeaderView* headerView;
    headerView = [[BMPredictionHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 0.0)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [headerView setTitle:[NSString stringWithFormat:@"%@: %@", _targetField[@"name"], _predictionResult ? _predictionResult[@"value"] : @"?"]];
    [headerView setConfidence:_predictionResult ? [_predictionResult[@"confidence"] floatValue] : 0.0/0.0];
    
    _predictionResultView = headerView;
    return headerView;
}

/////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
        return 88.0;
    else
        return 56.0;
}

@end
