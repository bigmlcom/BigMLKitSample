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

#import "BMSideDrawerTableViewCell.h"

@implementation BMSideDrawerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setAccessoryCheckmarkColor:[UIColor whiteColor]];

        UIColor* backgroundColor = nil;
        backgroundColor = [UIColor colorWithRed:122.0/255.0
                                          green:126.0/255.0
                                           blue:128.0/255.0
                                          alpha:1.0];

        UIView* backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [backgroundView setBackgroundColor:backgroundColor];
        [self setBackgroundView:backgroundView];
        
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setTextColor:[UIColor
                                      colorWithRed:230.0/255.0
                                      green:236.0/255.0
                                      blue:242.0/255.0
                                      alpha:1.0]];
        
        [self.textLabel setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:.5]];
        [self.textLabel setShadowOffset:CGSizeMake(0, 1)];
    }
    return self;
}

- (void)updateContentForNewContentSize {
    
    if ([[UIFont class] respondsToSelector:@selector(preferredFontForTextStyle:)]) {
        [self.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    } else {
        [self.textLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    }
}

@end
