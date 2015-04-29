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

#import "BMPredictionForm.h"

static NSMutableArray* gPredictionFormFields;

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@implementation BMPredictionForm {
    
    NSMutableDictionary* _values;
}

/////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super init]) {
        _values = [NSMutableDictionary dictionary];
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////////
- (void)setValue:(id)value forKey:(NSString*)key {
    
    [_values setObject:value forKey:key];
}

/////////////////////////////////////////////////////////////////////////////////
- (id)valueForKey:(NSString*)key {
    
    return [_values objectForKey:key];
}

/////////////////////////////////////////////////////////////////////////////////
- (NSArray*)fields {
    
    return gPredictionFormFields;
}

/////////////////////////////////////////////////////////////////////////////////
+ (void)addField:(NSDictionary*)fieldDescription {
    
    if (!gPredictionFormFields)
        gPredictionFormFields = [NSMutableArray array];
    [gPredictionFormFields addObject:fieldDescription];
}

/////////////////////////////////////////////////////////////////////////////////
+ (void)resetFields {
    
    gPredictionFormFields = nil;
}

@end
