//
//  MCSession+SessionIdentifier.h
//  BandwithJacker-mac
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCSession (SessionIdentifier)

@property (nonatomic, strong) NSString *sessionID;

@end
