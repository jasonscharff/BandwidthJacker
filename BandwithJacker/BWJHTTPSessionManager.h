//
//  BWJSessionManager.h
//  BandwithJacker
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface BWJHTTPSessionManager : NSObject

+ (instancetype)sharedManager;
- (void)downloadDataAtURL : (NSURL *)url
              bytesString : (NSString *)bytesString
                sessionID : (NSString *)sessionID;

@end
