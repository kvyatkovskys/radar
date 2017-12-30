//
//  FBManager.m
//  Circle
//
//  Created by Kviatkovskii on 30/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

#import "FBManager.h"

@implementation FBManager

+ (void) startConfiguration:(UIApplication *)application withOptions:(NSDictionary *)options {
    [[FBSDKApplicationDelegate sharedInstance] application: application didFinishLaunchingWithOptions: options];
}

+ (void) activateApp {
    [FBSDKAppEvents activateApp];
}

+ (BOOL)startApplication:(UIApplication *)application opneUrl:(NSURL *)url withOptions:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

@end
