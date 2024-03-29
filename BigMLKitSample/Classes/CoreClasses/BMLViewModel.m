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

#import "BMLViewModel.h"
#import "BMLResource.h"

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation BMLViewModel

//////////////////////////////////////////////////////////////////////////////////////
+ (BMLViewModel*)viewModel {
    
    static BMLViewModel* viewModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewModel = [BMLViewModel new];
    });
    return viewModel;
}

//////////////////////////////////////////////////////////////////////////////////////
- (void)createWorkflowWithConfigurator:(BMLWorkflowConfigurator*)configurator connector:(ML4iOS*)connector {
    
    [super createWorkflowWithConfigurator:configurator connector:connector];
    [self configureContextForResourceType:kFileEntityType uuid:self.currentResource.fullUuid];
}

@end
