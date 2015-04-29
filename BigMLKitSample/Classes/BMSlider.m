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

#import <QuartzCore/QuartzCore.h>

#import "BMSlider.h"

#define kValueFieldDefaultBorderColor [UIColor lightGrayColor]
#define kValueFieldSelectedBorderColor BMGreenColor
#define kValueFieldDefaultBorderWidth 0.5
#define kValueFieldSelectedBorderWidth 1.5

@implementation BMSliderEmpty


@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation UITextField (Padding)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
//////////////////////////////////////////////////////////////////////////////////////
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 2, bounds.origin.y + 2,
                      bounds.size.width - 6, bounds.size.height - 2);
}

//////////////////////////////////////////////////////////////////////////////////////
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
#pragma clang diagnostic pop

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMSlider () <UITextFieldDelegate>

@property (nonatomic, strong) UISlider* slider;

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMSlider {
    
    UILabel* _lowerLabel;
    UILabel* _upperLabel;
    UITextField* _valueField;
    dispatch_once_t _once;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {

    if (self = [super init]) {
        [self initializeSubviews];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)initializeSubviews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _slider = [UISlider new];
    
    _lowerLabel = [UILabel new];
    _upperLabel = [UILabel new];
    _valueField = [UITextField new];
    
    _lowerLabel.font = [UIFont systemFontOfSize:12.0];
    _lowerLabel.textAlignment = NSTextAlignmentLeft;
    _upperLabel.font = [UIFont systemFontOfSize:12.0];
    _upperLabel.textAlignment = NSTextAlignmentRight;

    _valueField.textAlignment = NSTextAlignmentRight;
    _valueField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _valueField.layer.borderWidth = 0.5;
    _valueField.layer.cornerRadius = 3;
    _valueField.font = [UIFont boldSystemFontOfSize:12.0];
    _valueField.delegate = self;
    
    _slider.continuous = YES;
    _slider.value = self.currentValue;
    [_slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(sliderValueDidEndChange:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_slider];
    [self addSubview:_lowerLabel];
    [self addSubview:_upperLabel];
    [self addSubview:_valueField];
    
    self.backgroundColor = [UIColor clearColor];
    _slider.backgroundColor = [UIColor clearColor];

    [self updateValues];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setEnabled:(BOOL)enabled {

    _slider.enabled = enabled;
    _valueField.enabled = enabled;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)updateValues {
    
    _valueField.text = [NSString stringWithFormat:[self valueFormatMask], [self valueFromSlider:_slider.value]];
    _upperLabel.text = [NSString stringWithFormat:[self valueFormatMask], self.maximumValue];
    _lowerLabel.text = [NSString stringWithFormat:[self valueFormatMask], self.minimumValue];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setUpConstraints {
    
    [self removeConstraints:self.constraints];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    _lowerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _valueField.translatesAutoresizingMaskIntoConstraints = NO;
    _upperLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _slider.translatesAutoresizingMaskIntoConstraints = NO;
    
    //-- contentView auto layout
    NSDictionary* views = NSDictionaryOfVariableBindings(_lowerLabel, _upperLabel, _valueField, _slider);
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_slider]-16-[_valueField(60)]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_lowerLabel(60)]-(>=32)-[_upperLabel(60)]-(76)-|"
                                             options: 0
                                             metrics:nil
                                               views:views]];

    float sliderTopMargin = 0;
    float paddingSlider2Label = 0;
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sliderTopMargin-[_slider]-paddingSlider2Label-[_lowerLabel]-0-|"
                                             options:0
                                             metrics:@{@"sliderTopMargin": @(sliderTopMargin),
                                                       @"paddingSlider2Label":@(paddingSlider2Label)}
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sliderTopMargin-[_slider]-paddingSlider2Label-[_upperLabel]-0-|"
                                             options:0
                                             metrics:@{@"sliderTopMargin": @(sliderTopMargin),
                                                       @"paddingSlider2Label":@(paddingSlider2Label)}
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_valueField(28)]-(>=4)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)updateConstraints {
    
    [self setUpConstraints];
    [super updateConstraints];
}

#pragma mark Value conversion
//////////////////////////////////////////////////////////////////////////////////////
- (float)currentValue {
    return [self valueFromSlider:_slider.value];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentValue:(float)value {

    _slider.value = [self sliderFromValue:value];
    [self updateValues];
}

//////////////////////////////////////////////////////////////////////////////////////
- (float)valueFromSlider:(float)sliderValue {
    
    float value = self.minimumValue + sliderValue * (self.maximumValue - self.minimumValue);
    if (_sliderStep > 0)
        value = roundf(value / _sliderStep);
    return value;
}

//////////////////////////////////////////////////////////////////////////////////////
- (float)sliderFromValue:(float)value {
    
    return (value - self.minimumValue) / (self.maximumValue - self.minimumValue);
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSString*)valueFormatMask {

    if (_sliderStep > 0)
        return @"%.0f";
    else
        return @"%.2f";
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setMinimumValue:(float)value {
    
    _minimumValue = value;
    [self updateValues];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)setMaximumValue:(float)value {
    
    _maximumValue = value;
    [self updateValues];
}

#pragma mark UITextFieldDelegate
//////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidBeginEditing:(UITextField*)textField {
    
    textField.layer.borderColor = kValueFieldSelectedBorderColor.CGColor;
    textField.layer.borderWidth = kValueFieldSelectedBorderWidth;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing:(UITextField*)textField {
    
    textField.layer.borderColor = kValueFieldDefaultBorderColor.CGColor;
    textField.layer.borderWidth = kValueFieldDefaultBorderWidth;
    
    _slider.value = [self sliderFromValue:[textField.text floatValue]];
    _valueField.text = [NSString stringWithFormat:[self valueFormatMask], [self valueFromSlider:_slider.value]];
}

//////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField*)textField {

    [self endEditing:YES];
    return YES;
}
#pragma mark UISliderDelegate
//////////////////////////////////////////////////////////////////////////////////////
- (void)sliderValueDidChange:(id)sender {

    _valueField.text = [NSString stringWithFormat:[self valueFormatMask], [self valueFromSlider:_slider.value]];
    _valueField.layer.borderColor = kValueFieldSelectedBorderColor.CGColor;
    _valueField.layer.borderWidth = kValueFieldSelectedBorderWidth;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)sliderValueDidEndChange:(id)sender {
    
    [self updateValues];
    _valueField.layer.borderColor = kValueFieldDefaultBorderColor.CGColor;
    _valueField.layer.borderWidth = kValueFieldDefaultBorderWidth;
}


@end
