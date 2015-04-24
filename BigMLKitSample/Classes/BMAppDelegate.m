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

#import "BMAppDelegate.h"

#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "BMDrawerVisualStateManager.h"

#import "BMResourceListViewController.h"
#import "BMPredictionViewController.h"

#import "BMLViewModel.h"
#import "BMLResource.h"

#include <objc/runtime.h>
#include <objc/message.h>

static void* kvoContext = &kvoContext;

@interface BMAppDelegate () <UIAlertViewDelegate>

@property (nonatomic,strong) MMDrawerController * drawerController;
@property (nonatomic) BOOL tryingToLogIn;

@end

@implementation BMAppDelegate {
    
    UINavigationController* _mainNavigationController;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    UIViewController* leftSideDrawerViewController = [[BMResourceListViewController alloc] init];
    UIViewController* centerViewController = [[BMPredictionViewController alloc] init];

    _mainNavigationController =
    [[UINavigationController alloc] initWithRootViewController:centerViewController];
    [_mainNavigationController setRestorationIdentifier:@"BMPredictionNavigationControllerRestorationKey"];
    
    UINavigationController* leftSideNavController = [[UINavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
    [leftSideNavController setRestorationIdentifier:@"BMResourcesNavigationControllerRestorationKey"];

    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:_mainNavigationController
                             leftDrawerViewController:leftSideNavController
                             rightDrawerViewController:nil];
    [self.drawerController setShowsShadow:NO];

    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumRightDrawerWidth:280.0];
    
    [self.drawerController setOpenDrawerGestureModeMask:
     MMOpenDrawerGestureModePanningNavigationBar     |
     MMOpenDrawerGestureModeBezelPanningCenterView   |
     MMOpenDrawerGestureModeCustom];
    
    [self.drawerController setCloseDrawerGestureModeMask:
     MMCloseDrawerGestureModePanningNavigationBar    |
     MMCloseDrawerGestureModeBezelPanningCenterView  |
     MMCloseDrawerGestureModeTapNavigationBar        |
     MMCloseDrawerGestureModeTapCenterView           |
     MMCloseDrawerGestureModePanningDrawerView       |
     MMCloseDrawerGestureModeCustom];
    
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController* drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         
         MMDrawerControllerDrawerVisualStateBlock block =
         [[BMDrawerVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
         if (block) {
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIColor * tintColor = [UIColor colorWithRed:29.0/255.0
                                          green:173.0/255.0
                                           blue:234.0/255.0
                                          alpha:1.0];
    [self.window setTintColor:tintColor];
    [self.window setRootViewController:self.drawerController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [[BMLViewModel viewModel] addObserver:self
                               forKeyPath:NSStringFromSelector(@selector(currentResource))
                                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                  context:kvoContext];

    return YES;
}

/////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString*)keypath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
    if ([keypath isEqualToString:NSStringFromSelector(@selector(currentResource))]) {
        
        NSString* predictionViewControllerName = [NSString stringWithFormat:@"BMConcretePredictionViewController%@",
                                                  [BMLViewModel viewModel].currentResource.name];
        Class _formClass = objc_allocateClassPair([BMPredictionViewController class],
                                                  [predictionViewControllerName UTF8String],
                                            0);
        if (_formClass)
            objc_registerClassPair(_formClass);

        BMPredictionViewController* predictionViewController = nil;
        if (_formClass)
            predictionViewController = [[_formClass alloc] init];
        else
            predictionViewController = [NSClassFromString(predictionViewControllerName) new];
        [predictionViewController setupFromModel:[BMLViewModel viewModel]];        
        [_mainNavigationController pushViewController:predictionViewController animated:YES];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - save/restore status
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    NSString * key = [identifierComponents lastObject];
    if([key isEqualToString:@"MMDrawer"]){
        return self.window.rootViewController;
    }
    else if ([key isEqualToString:@"BMPredictionNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).centerViewController;
    }
    else if ([key isEqualToString:@"BMOptionsNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).rightDrawerViewController;
    }
    else if ([key isEqualToString:@"BMResourcesNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).leftDrawerViewController;
    }
    else if ([key isEqualToString:@"MMExampleLeftSideDrawerController"]) {
        UIViewController * leftVC = ((MMDrawerController *)self.window.rootViewController).leftDrawerViewController;
        if([leftVC isKindOfClass:[UINavigationController class]]){
            return [(UINavigationController*)leftVC topViewController];
        }
        else {
            return leftVC;
        }
        
    }
    else if ([key isEqualToString:@"MMExampleRightSideDrawerController"]){
        UIViewController * rightVC = ((MMDrawerController *)self.window.rootViewController).rightDrawerViewController;
        if([rightVC isKindOfClass:[UINavigationController class]]){
            return [(UINavigationController*)rightVC topViewController];
        }
        else {
            return rightVC;
        }
    }
    return nil;
}

@end
