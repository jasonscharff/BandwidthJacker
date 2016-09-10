//
//  BWJMultipeerConnectivityController.m
//  BandwithJacker
//
//  Created by Jason Scharff on 9/9/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "BWJMultipeerConnectivityController.h"

@import MultipeerConnectivity;

//We are limited to 15 characters so I'm using abbreviations.
static NSString * const kBWJMultipeerConnectivityServiceType = @"bwj-mpc-service";

@interface BWJMultipeerConnectivityController() <MCNearbyServiceAdvertiserDelegate>

@property (nonatomic) MCNearbyServiceAdvertiser *serviceIdentifier;
@property (nonatomic) MCPeerID *peerID;
@property (nonatomic) MCSession *session;

@end


#pragma mark lifecycle

@implementation BWJMultipeerConnectivityController

+ (instancetype)sharedMultipeerConnectivityController {
    static dispatch_once_t onceToken;
    static BWJMultipeerConnectivityController *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc {
    [self.serviceIdentifier stopAdvertisingPeer];
}

#pragma mark advertising

- (void)startAdvertising {
    if(!self.serviceIdentifier) {
        self.serviceIdentifier = [[MCNearbyServiceAdvertiser alloc]initWithPeer:self.peerID
                                                                  discoveryInfo:nil
                                                                    serviceType:kBWJMultipeerConnectivityServiceType];
        self.serviceIdentifier.delegate = self;
    }
    [self.serviceIdentifier startAdvertisingPeer];
}


- (void)stopAdvertising {
    [self.serviceIdentifier stopAdvertisingPeer];
}

#pragma mark MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"an error with starting advertising peer = %@", error.localizedDescription);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    if([advertiser.serviceType isEqualToString:kBWJMultipeerConnectivityServiceType]) {
        invitationHandler(YES, self.session);
    } else {
        invitationHandler(NO, nil);
    }
}

#pragma mark getters
//Lazy init of the mcsession object.
- (MCSession *)session {
    if(!_session) {
        self.session = [[MCSession alloc]initWithPeer:_peerID
                                     securityIdentity:nil
                                 encryptionPreference:MCEncryptionNone];
    }
    return _session;
}
- (MCPeerID *)peerID {
    if(!_peerID) {
      _peerID = [[MCPeerID alloc]initWithDisplayName:[UIDevice currentDevice].name];
    }
    return _peerID;
}


@end
