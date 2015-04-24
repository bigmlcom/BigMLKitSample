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

#import <Foundation/Foundation.h>
#import "FXForms.h"

@class FXFormField;

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
@interface BMPredictionForm : NSObject <FXForm>

@property (weak) FXFormField* predictionTarget;
@property (strong) NSString* predictionResult;
@property (strong) NSString* predictionConfidence;
@property (strong) NSIndexPath* predictionTargetIndexPath;
@property (strong) NSIndexPath* oldPredictionTargetIndexPath;

+ (void)addField:(NSDictionary*)fieldDescription;
+ (void)resetFields;

@end

