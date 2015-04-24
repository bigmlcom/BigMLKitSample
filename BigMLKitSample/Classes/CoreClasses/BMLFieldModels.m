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

#import "BMLFieldModels.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    NSAssert(NO, @"Should not be here!!");
    return  nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLSliderFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  @(_rawValue);
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"currentValue"]) {
        [keyPaths addObject:@"rawValue"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLRangeSliderFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  @[@(_lowerValue), @(_upperValue)];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"currentValue"]) {
        [keyPaths addObject:@"lowerValue"];
        [keyPaths addObject:@"upperValue"];
    }
    
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLPopUpFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  _itemValue;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"currentValue"]) {
        NSArray* affectingKeys = @[@"itemValue"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLIndexedPopUpFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  @(_itemIndex);
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"currentValue"]) {
        NSArray* affectingKeys = @[@"itemIndex"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLRadioGroupFieldModel

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLTextFormFieldModel

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface BMLCheckBoxFieldModel ()


@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLCheckBoxFieldModel

- (id)currentValue {
 
    return [NSNumber numberWithBool:self.isSelected];
}

//////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)selectedState {
    
    return _isSelected ? NSOnState : NSOffState;
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"state"]) {
        NSArray* affectingKeys = @[@"isSelected"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    return keyPaths;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLTokenFieldModel

//////////////////////////////////////////////////////////////////////////////////////
- (id)currentValue {
    
    return  [_rawValue componentsSeparatedByString:@","];
}

//////////////////////////////////////////////////////////////////////////////////////
+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
    
    NSMutableSet* keyPaths = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    if ([key isEqualToString:@"currentValue"]) {
        [keyPaths addObject:@"rawValue"];
    }
    
    return keyPaths;
}


@end
