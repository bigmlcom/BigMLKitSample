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

#import "BMPredictionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMPredictionHeaderView ()

@property (nonatomic, strong) UILabel* predictionLabel;
@property (nonatomic, strong) UILabel* confidenceLabel;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMPredictionHeaderView

//////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

        [self setBackgroundColor:[UIColor colorWithRed:110./255.0
                                                 green:113.0/255.0
                                                  blue:115.0/255.0
                                                 alpha:1.0]];
        
        _predictionLabel = [[UILabel alloc] initWithFrame:(CGRect){20,16,280,30}];
        _confidenceLabel = [[UILabel alloc] initWithFrame:(CGRect){40,45,240,20}];
        [self addSubview:self.predictionLabel];
        [self addSubview:self.confidenceLabel];
        
        _predictionLabel.textAlignment = NSTextAlignmentCenter;
        _confidenceLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.predictionLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
        [self.confidenceLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        
        [self.predictionLabel setBackgroundColor:[UIColor clearColor]];
        [self.predictionLabel setTextColor:[UIColor colorWithRed:203.0/255.0
                                            green:206.0/255.0
                                             blue:209.0/255.0
                                            alpha:1.0]];
        
        [self setClipsToBounds:NO];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setTitle:(NSString*)title {
    
    _title = title;
    [self.predictionLabel setText:self.title];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setConfidence:(float)confidence {

    _confidence = confidence;
    [self.confidenceLabel setText:[NSString stringWithFormat:@"Confidence: %.4f", confidence]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraints {
    
    [self removeConstraints:self.constraints];
    
    self.translatesAutoresizingMaskIntoConstraints = YES;
    _predictionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _confidenceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* views = NSDictionaryOfVariableBindings(_predictionLabel, _confidenceLabel);
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_predictionLabel]-8-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[_confidenceLabel]-24-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_predictionLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:0.75
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_confidenceLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.25
                                                      constant:10.0]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)updateConstraints {
    
    [self setUpConstraints];
    [super updateConstraints];
}

@end
