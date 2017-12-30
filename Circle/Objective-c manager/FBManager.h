//
//  FBManager.h
//  Circle
//
//  Created by Kviatkovskii on 30/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FBManager: NSObject

+ (void) startConfiguration:(UIApplication *)application withOptions:(NSDictionary *)options;
+ (void) activateApp;
+ (BOOL) startApplication:(UIApplication *)application opneUrl:(NSURL *)url withOptions:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *) options;

@end
