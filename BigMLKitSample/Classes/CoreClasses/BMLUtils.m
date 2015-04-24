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

#import "BMLUtils.h"

@implementation BMLUtils

+ (NSDateFormatter*)bmlDateFormatter {
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"y-M-d'T'HH:mm:ss.SSSSSS"];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return df;
}

+ (NSDateFormatter*)alternateDateFormatter {
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"y-M-d'T'HH:mm:ss"];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return df;
}

+ (NSDate*)dateFromString:(NSString*)dateString {
 
    return [[self bmlDateFormatter] dateFromString:dateString] ?:
    [[self alternateDateFormatter] dateFromString:dateString];
}

+ (NSString*)stringFromDate:(NSDate*)date {
    
    return [[self bmlDateFormatter] stringFromDate:date];
}

@end
