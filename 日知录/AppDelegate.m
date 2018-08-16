//
//  AppDelegate.m
//  日知录
//
//  Created by 灿灿 on 2018/1/4.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import <easyar/engine.oc.h>
#import "BeginController.h"

NSString * key = @"----";
NSString * cloud_server_address = @"----";
NSString * cloud_key = @"----";
NSString * cloud_secret = @"----";
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *vc = [storyboard instantiateInitialViewController];

    
    BeginController *vc = [[BeginController alloc] init];

    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    (void)application;
    (void)launchOptions;
    if (![easyar_Engine initialize:key]) {
        NSLog(@"Initialization Faild");
    }
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    (void)application;
    [easyar_Engine onPause];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    (void)application;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    (void)application;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    (void)application;
    [easyar_Engine onResume];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    (void)application;
}


@end
