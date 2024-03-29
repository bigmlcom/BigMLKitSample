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

#import "BML4iOS.h"
#import "BMLUtils.h"
#import "BMLResource.h"

#define kBigMLUsername @"sdesimone"
#define kBigMLApiKey @"7a2bc92761fe9a4da0e1d96dc9d46da752b54b9a"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BML4iOS

//////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)canConnect {
    
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    
    if (self = [super initWithUsername:kBigMLUsername
                                   key:kBigMLApiKey
                       developmentMode:YES]) {
     
        _asyncSessionToken = [[NSUUID UUID] UUIDString];
    }
    return self;
}

@end