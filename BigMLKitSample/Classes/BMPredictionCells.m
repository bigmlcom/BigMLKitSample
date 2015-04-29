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

#import "BMPredictionFieldValues.h"
#import "BMSlider.h"
#import "BMToolbar.h"
#import "BMPredictionCells.h"
#import "BMPredictionForm.h"

#import <QuartzCore/QuartzCore.h>

#define kBMPredictionCellNotIncludedHeight 46
#define kBMPredictionCellIncludedHeight 92

NSString* const kBMPredictionDoPredictionNotification = @"kBMPredictionDoPredictionNotification";

//////////////////////////////////////////////////////////////////////////////////////
static inline void FXFormLabelSetMinFontSize(UILabel* label, CGFloat fontSize) {
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    
    if (![label respondsToSelector:@selector(setMinimumScaleFactor:)])
        label.minimumFontSize = fontSize;
    else
#endif
        label.minimumScaleFactor = fontSize / label.font.pointSize;
}

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMPredictionBaseCell ()

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMPredictionBaseCell {
    
    UILabel* _mainLabel;
    UIButton* _targetButton;
    BMButtonToolbar* _toolbar;
    dispatch_once_t _cellSetupToken;
    UIView* _cellContent;
}

@synthesize field = _field;

//////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier ?: NSStringFromClass([self class])])) {

        [self performSelector:@selector(setUpConstraints) withObject:nil afterDelay:0.0];
        [self setUpCell];
        self.layer.cornerRadius = 16;
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMPredictionForm*)form {
    
    return (BMPredictionForm*)self.field.form;
}

//////////////////////////////////////////////////////////////////////////////////////
- (BMPredictionFieldValue*)fieldValue {
    
    return (BMPredictionFieldValue*)self.field.value;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)resetPredictionTarget {
    
    if (self.form.predictionTarget) {
        self.form.oldPredictionTargetIndexPath = self.form.predictionTargetIndexPath;
        self.form.predictionTargetIndexPath = nil;
        self.form.predictionTarget = nil;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (UITableView*)tableView {
    
    UIView* view = self;
    while ((view = view.superview))
        if ([view isKindOfClass:[UITableView class]])
            return (id)view;
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setField:(FXFormField*)field {
    
    _field = field;
    [self reloadCell];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSNumber*)cellBodyHeight {

    return @kBMPredictionCellNotIncludedHeight;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraintsForToolbarInViews:(NSDictionary*)views {
    
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraintsForSwipableViewInViews:(NSDictionary*)views {

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[swipableLabel]|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"swipableLabel":_cellContent}]];

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[swipableLabel]|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"swipableLabel":_cellContent}]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraintsForContentViewInViews:(NSDictionary*)views {
 
    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[_cellBody]-16-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_mainLabel]-0-|"
                                             options: 0
                                             metrics:nil
                                               views:views]];
    
    [self.contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_mainLabel]-[_cellBody(cellBodyHeight)]-4-|"
                                             options: 0
                                             metrics:@{@"cellBodyHeight":[self cellBodyHeight]}
                                               views:views]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraints {
    
    [self removeConstraints:self.constraints];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _cellBody.translatesAutoresizingMaskIntoConstraints = NO;
    _cellContent.translatesAutoresizingMaskIntoConstraints = NO;
    _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    
    _targetButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==self)]|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"contentView":self.contentView,
                                                       @"self": self}]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView(==self)]|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"contentView":self.contentView,
                                                       @"self": self}]];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(_mainLabel, _cellBody, _toolbar);
    
    [self setUpConstraintsForContentViewInViews:views];
    [self setUpConstraintsForToolbarInViews:views];
    [self setUpConstraintsForSwipableViewInViews:views];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)updateConstraints {
    
    [self setUpConstraints];
    [super updateConstraints];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)refresh {
    
    _targetButton.selected = (_field && _field == self.form.predictionTarget);
}

//////////////////////////////////////////////////////////////////////////////////////
- (UIView*)optionsToolbar {
    
    _toolbar = [[BMButtonToolbar alloc] initWithFrame:CGRectZero];
    _toolbar.clearsContextBeforeDrawing = YES;
    _toolbar.clipsToBounds = YES;
    _toolbar.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _toolbar.backgroundColor = [UIColor redColor];
    
    return _toolbar;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)showOptionsToolbar {
    
    if (_toolbar.hidden) {
        
        _toolbar.hidden = NO;
        _mainLabel.hidden = YES;
        
    } else {
        
        _toolbar.hidden = YES;
        _mainLabel.hidden = NO;
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (UIView*)viewWithImageName:(NSString *)imageName {
    
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpCell {
        
    dispatch_once(&_cellSetupToken, ^{
        
        self.userInteractionEnabled = YES;
        
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _mainLabel.textAlignment = NSTextAlignmentCenter;
        _mainLabel.textColor = BMGreenColor;
        _mainLabel.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        _mainLabel.font = [UIFont boldSystemFontOfSize:17];
        FXFormLabelSetMinFontSize(_mainLabel, 11);
        
        _mainLabel.userInteractionEnabled = YES;
        
        _cellBody = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self.contentView addSubview:_cellBody];
        [self.contentView addSubview:_mainLabel];
        [self.contentView addSubview:_targetButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _cellContent = [[UIView alloc] initWithFrame:CGRectZero];
        [_mainLabel addSubview:_cellContent];
        self.accessoryView = [self optionsToolbar];
    });
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)reloadCell {
    
    [self updateValues];
    [self setNeedsLayout];
}

#define FXFormFieldPaddingLeft 10
#define FXFormFieldPaddingRight 10
//////////////////////////////////////////////////////////////////////////////////////
- (void)updateValues {
    
    NSAssert(!self.field ||
             [self.field.value isKindOfClass:[BMPredictionFieldValue class]], @"Wrong Field Type");

    if (!self.field) return;
    
    _mainLabel.text = self.field.title;
    
    if (self.field == [self.form predictionTarget]) {
        _mainLabel.textColor = BMGreenColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }

    if (self.fieldValue.isIncluded) {
        _mainLabel.textColor = BMGreenColor;
    } else {
        _mainLabel.textColor = [UIColor grayColor];
    }
}

#pragma mark FXFormFieldDelegate
//////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)heightForField:(FXFormField*)field width:(CGFloat)width {

    return kBMPredictionCellIncludedHeight;
    if ([(BMPredictionFieldValue*)field isIncluded])
        return kBMPredictionCellIncludedHeight;
    else
        return kBMPredictionCellNotIncludedHeight;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)heightForField:(FXFormField*)field {

    return kBMPredictionCellIncludedHeight;
    if ([(BMPredictionFieldValue*)field isIncluded])
        return kBMPredictionCellIncludedHeight;
    else
        return kBMPredictionCellNotIncludedHeight;
}

@end
#pragma mark - BMPredictionRangeCell
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMPredictionRangeCell ()

- (void)setSliderStep:(unsigned int)step;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMPredictionRangeCell  {
    
    BMSlider* _slider;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setSliderStep:(unsigned int)step {
    _slider.sliderStep = step;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setField:(FXFormField*)field {
    
    BMPredictionRange* range = field.value;
    if (!range) {
        range = [BMPredictionRange new];
        range.range = FPRangeMake([field.options[0] floatValue],
                                  [field.options[1] floatValue] - [field.options[0] floatValue]);
        range.currentValue = @(range.range.location + range.range.length / 2);
        field.value = range;
    }
    
    _slider.minimumValue = range.range.location;
    _slider.maximumValue = range.range.location + range.range.length;
    _slider.currentValue = [range.currentValue floatValue];
    
    [super setField:field];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpCell {
    
    [super setUpCell];
    
    _slider = [BMSlider new];
    [_slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self.cellBody addSubview:_slider];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraints {
    
    [self removeConstraints:self.constraints];

    [super setUpConstraints];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[slider]|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"slider":_slider}]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[slider]|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"slider":_slider}]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)updateValues {
    
    [super updateValues];
    
    BMPredictionRange* range = self.field.value;
    _slider.minimumValue = range.range.location;
    _slider.maximumValue = range.range.location + range.range.length;
    _slider.currentValue = [range.currentValue floatValue];
    _slider.enabled = range.isIncluded;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)valueChanged {
    
    [self.fieldValue setCurrentValue:@(_slider.currentValue)];
    if (self.field.action) self.field.action(self);
    [self resetPredictionTarget];
}

@end
#pragma mark - BMPredictionOptionCell
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMPredictionOptionCell () <UIPickerViewDelegate, UIPickerViewDataSource>
@end

@implementation BMPredictionOptionCell {
    
    UIPickerView* _picker;
    UILabel* _pickedValue;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setField:(FXFormField*)field {
    
    BMPredictionOption* option = field.value;
    if (!option) {
        option = [BMPredictionOption new];
        option.options = field.options;
        field.value = option;
    }
    [super setField:field];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpCell {
    [super setUpCell];
    
    _picker = [[UIPickerView alloc] init];
    _picker.dataSource = self;
    _picker.delegate = self;
    
    _pickedValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [_pickedValue setTextAlignment:NSTextAlignmentCenter];
    _pickedValue.font = [UIFont systemFontOfSize:18.0];
    _pickedValue.textColor = [UIColor darkGrayColor];
    
    [self.cellBody addSubview:_pickedValue];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraints {
    
    [self removeConstraints:self.constraints];
    [super setUpConstraints];
    
    _pickedValue.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[pickedValue]-|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"pickedValue":_pickedValue}]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[pickedValue]-6-|"
                                             options: 0
                                             metrics:nil
                                               views:@{@"pickedValue":_pickedValue}]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)updateValues {
    
    [super updateValues];

    NSString* pickerValue = self.fieldValue.currentValue;
    NSUInteger index = pickerValue ? [self.field.options indexOfObject:pickerValue]: NSNotFound;
    if (self.field.placeholder) {
        index = (index == NSNotFound)? 0: index + 1;
    }
    if (index != NSNotFound) {
        [_picker selectRow:index inComponent:0 animated:NO];
    } else {
        [_picker selectRow:0 inComponent:0 animated:NO];
    }
    
    _pickedValue.text = pickerValue;
}

//////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////
- (UIView*)inputView {
    return _picker;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)didSelectWithTableView:(UITableView *)tableView controller:(__unused UIViewController *)controller {
    
    [self becomeFirstResponder];
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView {
    return 1;
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component {
    return [self.field.options count] + (self.field.placeholder? 1: 0);
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)pickerView:(__unused UIPickerView*)pickerView
            titleForRow:(NSInteger)row
           forComponent:(__unused NSInteger)component {
    
    if (row == 0)
        return [self.field.placeholder fieldDescription] ?: [self.field optionDescriptionAtIndex:0];
    else
        return [self.field optionDescriptionAtIndex:row - (self.field.placeholder? 1: 0)];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)pickerView:(__unused UIPickerView*)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(__unused NSInteger)component {

    if (!self.field.placeholder || row > 0)
        [self.fieldValue setCurrentValue:self.field.options[row - (self.field.placeholder? 1: 0)]];
    
    [self reloadCell];
    
    if (self.field.action)
        self.field.action(self);
    
    [self resetPredictionTarget];
    [self resignFirstResponder];
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMPredictionDiscreteRangeCell

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpCell {
    
    [super setUpCell];
    [self setSliderStep:1];
}

@end

