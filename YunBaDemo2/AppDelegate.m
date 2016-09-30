//
//  AppDelegate.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/14.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalAttribute.h"
#import "YunBaService.h"
#import "Notifications.h"
@import UserNotifications;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 这玩意儿可以用来获取字体的fontName
//    NSArray *familyNames = [UIFont familyNames];
//    for(NSString *familyName in familyNames ) {
//        printf("Family: %s \n",[familyName UTF8String]);
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
//        for(NSString *fontName in fontNames ){
//            printf("\tFont: %s \n",[fontName UTF8String]);
//        }
//    }
    // Override point for customization after application launch.
    
    // set yunba log level
    kYBLogLevel = kYBLogLevelDebug;
    
    YBSetupOption *setupOption = [[YBSetupOption alloc] init];
    // set api timeout
    [setupOption setAPITimeout:kYbDefaultApiTimeout];
    
    // set heartbeat interval
    [setupOption setHeartbeatInterval:kYBDefaultHeartbeatInterval];
    
    // set api retry
    [setupOption setAPIRetryEnabled:kYBDefaultApiRetryEnabled];
    
    // uncomment to setup yunba service, refer to http://www.yunba.io to get an appkey
    [YunBaService setupWithAppkey:@"57de472618fbf4e0707299c9"];
    
    // register remote notification
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self registerRemoteNotification];;
    });
    // clear badge
    application.applicationIconBadgeNumber = 0;
    return YES;
}

-(void)registerRemoteNotification {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            granted ? NSLog(@"author success!") : NSLog(@"author failed!");
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
              [[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else {
        NSLog(@"ios version is too old,register remote notification failed");
        //        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}
- (void)unregisterRemoteNotification {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
// for device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"get Device Token: %@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    //[Notifications sendNotification:[NSString stringWithFormat:@"get Device Token:%@",deviceToken]];
    // uncomment to store device token to YunBa
    [YunBaService storeDeviceToken:deviceToken resultBlock:^(BOOL succ, NSError *error) {
        if (succ) {
            NSLog(@"store device token to YunBa succ");
            //[Notifications sendNotification:@"PS.store device token to YunBa succ"];
        } else {
            NSLog(@"store device token to YunBa failed due to : %@, recovery suggestion: %@", error, [error localizedRecoverySuggestion]);
            [Notifications sendNotification:[NSString stringWithFormat:@"store device token to YunBa failed due to : %@, recovery suggestion: %@", error, [error localizedRecoverySuggestion]]];
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    if ([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location != NSNotFound) {
        NSLog(@"apns is NOT supported on simulator, run your Application on a REAL device to get device token");
    }
    
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError Error: %@", error);
    [Notifications sendNotification:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError Error: %@", error]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[Notifications sendNotification:[NSString stringWithFormat:@"received:%@",userInfo]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // clear badge
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
