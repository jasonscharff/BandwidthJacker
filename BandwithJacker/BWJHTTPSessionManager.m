//
//  BWJSessionManager.m
//  BandwithJacker
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "BWJHTTPSessionManager.h"

#import "BWJMultipeerConnectivityController.h"

static long kBWJSendThreshold = 1 * 10^7;




@implementation BWJHTTPSessionManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static BWJHTTPSessionManager *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)downloadDataAtURL : (NSURL *)url
              bytesString : (NSString *)bytesString
                sessionID : (NSString *)sessionID {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:bytesString forHTTPHeaderField:@"Range"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURL *filePath = [[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]]URLByAppendingPathComponent:[[NSUUID UUID]UUIDString]];
                       
    __block long lastByteSent = 0;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if(downloadProgress.completedUnitCount-lastByteSent > kBWJSendThreshold) {
            NSData *downloadedData = [NSData dataWithContentsOfURL:filePath];
            NSData *dataToSend = [downloadedData subdataWithRange:NSMakeRange(lastByteSent, downloadedData.length-lastByteSent)];
            lastByteSent = downloadedData.length;
            [[BWJMultipeerConnectivityController sharedMultipeerConnectivityController]sendData:dataToSend
                                                                         toSessionWithSessionID:sessionID];
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return filePath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            NSData *downloadedData = [NSData dataWithContentsOfURL:filePath];
            NSData *dataToSend = [downloadedData subdataWithRange:NSMakeRange(lastByteSent, downloadedData.length-lastByteSent)];
            if(dataToSend) {
                lastByteSent = downloadedData.length;
                [[BWJMultipeerConnectivityController sharedMultipeerConnectivityController]sendData:dataToSend
                                                                             toSessionWithSessionID:sessionID];
            }


    }];
    
    [downloadTask resume];
}

@end
