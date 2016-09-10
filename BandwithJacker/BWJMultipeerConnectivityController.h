//
//  BWJMultipeerConnectivityController.h
//  BandwithJacker
//
//  Created by Jason Scharff on 9/9/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWJMultipeerConnectivityController : NSObject

+ (instancetype)sharedMultipeerConnectivityController;
- (void)startAdvertising;
- (void)stopAdvertising;

@end
