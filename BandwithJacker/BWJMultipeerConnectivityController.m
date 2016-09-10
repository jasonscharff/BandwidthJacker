//
//  BWJMultipeerConnectivityController.m
//  BandwithJacker
//
//  Created by Jason Scharff on 9/9/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "BWJMultipeerConnectivityController.h"

#import "MCSession+SessionIdentifier.h"

#import "BWJHTTPSessionManager.h"

@import MultipeerConnectivity;

//We are limited to 15 characters so I'm using abbreviations.
static NSString * const kBWJMultipeerConnectivityServiceType = @"bwj-mpc-service";

@interface BWJMultipeerConnectivityController() <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>

@property (nonatomic) MCNearbyServiceAdvertiser *serviceIdentifier;
@property (nonatomic) MCPeerID *peerID;
@property (nonatomic) NSMutableDictionary <NSString *, MCSession *> *sessions;

@property (nonatomic) MCPeerID *masterPeer;


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
        MCSession *session = [[MCSession alloc]initWithPeer:_peerID
                                           securityIdentity:nil
                                       encryptionPreference:MCEncryptionNone];
        //We don't know the server UUID here so we'll use our own.
        //Only the mac app actually interfaces with the server.
        session.sessionID = [[NSUUID UUID]UUIDString];
        
        session.delegate = self;
        
        invitationHandler(YES, session);
    } else {
        invitationHandler(NO, nil);
    }
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if(state == MCSessionStateConnected) {
        self.sessions[session.sessionID] = session;
    } else {
        if(self.sessions[session.sessionID]) {
            [self.sessions removeObjectForKey:session.sessionID];
        }
    }
}

- (void)sendData : (NSData *)data toSessionWithSessionID : (NSString *)sessionID {
    MCSession *session = self.sessions[sessionID];
    if(!sessionID) {
        NSLog(@"we need a session...");
        return;
    }
    NSError *error;
    //We badly need to append an order to the data because otherwise the order would get fucked
    //up and our entire data would be corrupted.
    [session sendData:data toPeers:@[self.masterPeer] withMode:MCSessionSendDataReliable error:&error];
    if(error) {
        NSLog(@"error sending data = %@", error.localizedDescription);
    }
    
}

- (void)sendTerminalDataToSessionWithID : (NSString *)sessionID {
    NSString *endSignalString = @"DID_FINISH_DOWNLOAD";
    NSData *endSignalData = [endSignalString dataUsingEncoding:NSUTF8StringEncoding];
    MCSession *session = self.sessions[sessionID];
    if(!sessionID) {
        NSLog(@"we need a session..");
        return;
    }
    NSError *error;
    [session sendData:endSignalData toPeers:@[self.masterPeer] withMode:MCSessionSendDataReliable error:&error];
    if(error) {
        NSLog(@"error sending terminal signal");
    }
    
}

#pragma mark getters
- (MCPeerID *)peerID {
    if(!_peerID) {
      _peerID = [[MCPeerID alloc]initWithDisplayName:[UIDevice currentDevice].name];
    }
    return _peerID;
}

#pragma mark MCSessionDelegate

- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID {
    //Begin a download request.
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    
    if(error) {
        NSLog(@"error with json = %@", error.localizedDescription);
    } else {
        NSURL *url = [NSURL URLWithString:json[@"url"]];
        NSString *bytesString = json[@"bytes"];
        
        [[BWJHTTPSessionManager sharedManager]downloadDataAtURL:url
                                                    bytesString:bytesString
                                                      sessionID:session.sessionID];
    }
    

    
    
}

- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID {
    //We will ignore this.
}

- (void)session:(MCSession *)session
didReceiveCertificate:(NSArray *)certificate
       fromPeer:(MCPeerID *)peerID
certificateHandler:(void (^)(BOOL))certificateHandler {
 //Ignore.
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    //Another function we have to ignore.
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    //Another thing to ignore.
}


@end
