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

#import "BMToolbar.h"

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@implementation BMToolbar

/////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
}

@end


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@implementation BMButtonToolbar {
 
    NSPointerArray* _items;
    NSPointerArray* _spacers;
}

/////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        _items = [NSPointerArray weakObjectsPointerArray];
        _spacers = [NSPointerArray weakObjectsPointerArray];
        [self setUserInteractionEnabled: YES];
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////////
- (UIView*)spacerView {

    return [UIView new];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)setItems:(NSArray*)items animated:(BOOL)animated {

    for (UIView* item in items) {
        NSAssert([item isKindOfClass:[UIView class]], @"Trying to set an toolbar item which is not a UIView.");

        [_items addPointer:(__bridge void*)item];
        item.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView* spacer = [self spacerView];
        spacer.translatesAutoresizingMaskIntoConstraints = NO;
        [_spacers addPointer:(__bridge void*)spacer];
        
        [self addSubview:item];
        [self addSubview:spacer];
    }

    UIView* spacer = [self spacerView];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [_spacers addPointer:(__bridge void*)spacer];
    [self addSubview:spacer];

    [self setNeedsUpdateConstraints];
}

@end
