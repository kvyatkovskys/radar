//
//  FBPlacesManager.h
//  Circle
//
//  Created by Kviatkovskii on 30/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKPlacesKit/FBSDKPlacesKit.h>

@interface FBPlacesManager : NSObject

- (void)findPlacesForLocation:(CLLocation *)location;

@end
