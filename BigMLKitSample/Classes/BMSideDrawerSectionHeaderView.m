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

#import "BMSideDrawerSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@interface BMSideDrawerSectionHeaderView ()
@property (nonatomic, strong) UILabel * label;
@end

@implementation BMSideDrawerSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        [self setBackgroundColor:[UIColor colorWithRed:110./255.0
                                                 green:113.0/255.0
                                                  blue:115.0/255.0
                                                 alpha:1.0]];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.bounds)-28,CGRectGetWidth(self.bounds)-30, 22)];

        if ([[UIFont class] respondsToSelector:@selector(preferredFontForTextStyle:)]){
            [self.label setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        }
        else {
             [self.label setFont:[UIFont boldSystemFontOfSize:12.0]];
        }
        
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setTextColor:[UIColor colorWithRed:203.0/255.0
                                            green:206.0/255.0
                                             blue:209.0/255.0
                                            alpha:1.0]];
        [self.label setShadowOffset:CGSizeMake(0, 1)];
        [self.label setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:.5]];
        [self.label setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:self.label];
        [self setClipsToBounds:NO];        
    }
    return self;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    [self.label setText:[self.title uppercaseString]];
}

-(void)drawRectt:(CGRect)rect{
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.373 green: 0.388 blue: 0.404 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.216 green: 0.231 blue: 0.243 alpha: 1];
    UIColor* color3 = [UIColor colorWithRed: 0.451 green: 0.463 blue: 0.475 alpha: 1];
    UIColor* color4 = [UIColor colorWithRed: 0.184 green: 0.2 blue: 0.212 alpha: 1];
    UIColor* fillColor2 = [UIColor colorWithRed: 0.373 green: 0.388 blue: 0.404 alpha: 0];
    
    //// Gradient Declarations
    NSArray* gradient2Colors = [NSArray arrayWithObjects:
                                (id)color.CGColor,
                                (id)fillColor2.CGColor, nil];
    CGFloat gradient2Locations[] = {0, 1};
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradient2Colors, gradient2Locations);
    
    //// Frames
    CGRect frame = CGRectMake(0, -1, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)+1);
    
    
    //// Fill Drawing
    CGRect fillRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) - 1);
    UIBezierPath* fillPath = [UIBezierPath bezierPathWithRect: fillRect];
    CGContextSaveGState(context);
    [fillPath addClip];
    CGContextDrawLinearGradient(context, gradient2,
                                CGPointMake(CGRectGetMidX(fillRect), CGRectGetMinY(fillRect)),
                                CGPointMake(CGRectGetMidX(fillRect), CGRectGetMaxY(fillRect)),
                                0);
    CGContextRestoreGState(context);
    
    
    //// TopStroke Drawing
    UIBezierPath* topStrokePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), 1)];
    [color4 setFill];
    [topStrokePath fill];
    
    
    //// Highlight Drawing
    UIBezierPath* highlightPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 1, CGRectGetWidth(frame), 1)];
    [color3 setFill];
    [highlightPath fill];
    
    
    //// BottomStroke Drawing
    UIBezierPath* bottomStrokePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + CGRectGetHeight(frame) - 1, CGRectGetWidth(frame), 1)];
    [color2 setFill];
    [bottomStrokePath fill];
    
    
    //// Cleanup
    CGGradientRelease(gradient2);
    CGColorSpaceRelease(colorSpace);
    
}

@end
