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

#import "BMLWorkflowView.h"
#import "BMLWorkflowTaskSequence.h"
#import "BMLWorkflowTask+Private.h"

#import "BMLWorkflowModel.h"

#import <objc/message.h>

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLWorkflowView ()

@property (nonatomic, readwrite, strong) BMLWorkflowTask* task;
@property (nonatomic, strong) BMLWorkflowModel* viewModel;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLWorkflowView {
    
    UIImageView* _progressView;
    UILabel* _progressMessage;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithTask:(BMLWorkflow*)task
                   viewModel:(BMLWorkflowModel*)model {
    
    if (self = [super initWithFrame:CGRectZero]) {

        _progressView = [UIImageView new];
        _progressView.animationDuration = 19/30.0;
        _progressView.animationImages = @[[UIImage imageNamed:@"00.png"],
                                          [UIImage imageNamed:@"01.png"],
                                          [UIImage imageNamed:@"02.png"],
                                          [UIImage imageNamed:@"03.png"],
                                          [UIImage imageNamed:@"04.png"],
                                          [UIImage imageNamed:@"05.png"],
                                          [UIImage imageNamed:@"06.png"],
                                          [UIImage imageNamed:@"07.png"],
                                          [UIImage imageNamed:@"08.png"],
                                          [UIImage imageNamed:@"09.png"],
                                          [UIImage imageNamed:@"10.png"],
                                          [UIImage imageNamed:@"11.png"],
                                          [UIImage imageNamed:@"12.png"],
                                          [UIImage imageNamed:@"13.png"],
                                          [UIImage imageNamed:@"14.png"],
                                          [UIImage imageNamed:@"15.png"],
                                          [UIImage imageNamed:@"16.png"],
                                          [UIImage imageNamed:@"17.png"],
                                          [UIImage imageNamed:@"18.png"]];
        _progressView.backgroundColor = [UIColor redColor];
        [self addSubview:_progressView];
        
        _progressMessage = [UILabel new];
        _progressMessage.text = @"";
        _progressMessage.textAlignment = NSTextAlignmentCenter;
        _progressMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self addSubview:_progressMessage];
        
        [model.workflow addObserver:self
                         forKeyPath:NSStringFromSelector(@selector(bmlStatus))
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                            context:NULL];
        
        [model.workflow addObserver:self
                         forKeyPath:NSStringFromSelector(@selector(currentTask))
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                            context:NULL];
        
        _viewModel = model;
        
        [self setConstraints];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {

    if (self.superview) {
        [_viewModel.workflow removeObserver:self forKeyPath:NSStringFromSelector(@selector(bmlStatus))];
        [_viewModel.workflow removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentTask))];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSuperview {

    [_viewModel.workflow removeObserver:self forKeyPath:NSStringFromSelector(@selector(bmlStatus))];
    [_viewModel.workflow removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentTask))];

    [super removeFromSuperview];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
    if (self.superview.isHidden) return;
    
    //-- change[NSKeyValueChangeOldKey] can be both nil and @(0), so we need to check
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(bmlStatus))] &&
        (!change[NSKeyValueChangeOldKey] ||
         [change[NSKeyValueChangeNewKey] intValue] != [change[NSKeyValueChangeOldKey] intValue])) {
        
            if (_task.bmlStatus != BMLWorkflowTaskUndefined &&
                _task.bmlStatus != BMLWorkflowTaskEnded &&
                _task.bmlStatus != BMLWorkflowTaskFailed &&
                ([change[NSKeyValueChangeOldKey] intValue] == BMLWorkflowTaskUndefined ||
                 !change[NSKeyValueChangeOldKey])) {
                    
                    [self startProgressWithRate:0.1 increment:0.1];
                    
                } else if (_task.bmlStatus == BMLWorkflowTaskEnded) {
                    
                    [self stopProgress];
                    
                } else if (_task.bmlStatus == BMLWorkflowTaskFailed) {
                    
                    [self stopProgress];
                }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(currentTask))]) {
            
            _progressMessage.text = _viewModel.workflow.currentTask.message;
        }
}

/////////////////////////////////////////////////////////////////////////////////
- (void)setConstraints {

    _progressView.translatesAutoresizingMaskIntoConstraints = NO;
    _progressMessage.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressMessage
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:100.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressMessage
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)startProgressWithRate:(float)interval increment:(float)increment {

    [_progressView startAnimating];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)stopProgress {
    
    [_progressView stopAnimating];
}

@end
