//
//  FBPlacesManager.m
//  Circle
//
//  Created by Kviatkovskii on 30/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

#import "FBPlacesManager.h"

@interface FBPlacesManager()

@property (nonatomic, strong) FBSDKPlacesManager *placesManager;

@end

@implementation FBPlacesManager

- (void)findPlacesForLocation:(CLLocation *)location {
    NSLog(@"%@", location);
    FBSDKGraphRequest *graphRequest = [self.placesManager
                                       placeSearchRequestForLocation: location
                                       searchTerm: nil
                                       categories: @[@"ARTS_ENTERTAINMENT",
                                                     @"EDUCATION",
                                                     @"FITNESS_RECREATION",
                                                     @"FOOD_BEVERAGE",
                                                     @"HOTEL_LODGING",
                                                     @"MEDICAL_HEALTH",
                                                     @"SHOPPING_RETAIL",
                                                     @"TRAVEL_TRANSPORTATION"]
                                       fields: @[FBSDKPlacesFieldKeyName,
                                                 FBSDKPlacesFieldKeyAbout,
                                                 FBSDKPlacesFieldKeyPlaceID]
                                       distance: 1000
                                       cursor: nil];
    [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@\n%@\n%@", connection, result, error);
    }];
    
    [self.placesManager generatePlaceSearchRequestForSearchTerm:nil
                                                     categories: @[@"ARTS_ENTERTAINMENT",
                                                                   @"EDUCATION",
                                                                   @"FITNESS_RECREATION",
                                                                   @"FOOD_BEVERAGE",
                                                                   @"HOTEL_LODGING",
                                                                   @"MEDICAL_HEALTH",
                                                                   @"SHOPPING_RETAIL",
                                                                   @"TRAVEL_TRANSPORTATION"]
                                                         fields:@[FBSDKPlacesFieldKeyName,
                                                                  FBSDKPlacesFieldKeyAbout,
                                                                  FBSDKPlacesFieldKeyPlaceID]
                                                       distance:1000
                                                         cursor:nil
                                                     completion:^(FBSDKGraphRequest * _Nullable graphRequest, CLLocation * _Nullable location, NSError * _Nullable error) {
                                                         if (graphRequest) {
                                                             [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                                 // Handle the response.
                                                                 // The result will contain the JSON for the place search.
                                                                  NSLog(@"%@\n%@\n%@", connection, result, error);
                                                             }];
                                                         }
                                                     }];
}

@end
