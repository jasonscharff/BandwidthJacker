//
//  MCSession+SessionIdentifier.m
//  BandwithJacker-mac
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "MCSession+SessionIdentifier.h"

#import <objc/runtime.h>


@implementation MCSession (SessionIdentifier)
@dynamic sessionID;


- (void)setSessionID:(NSString *)sessionID {
    objc_setAssociatedObject(self, @selector(sessionID), sessionID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)sessionID {
    return objc_getAssociatedObject(self, @selector(sessionID));
}


@end
