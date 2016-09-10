//
//  ViewController.m
//  BandwithJacker
//
//  Created by Jason Scharff on 9/9/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "BWJMainViewController.h"

#import "BWJMultipeerConnectivityController.h"

@interface BWJMainViewController ()

@end

@implementation BWJMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //Search for any devices.
    [[BWJMultipeerConnectivityController sharedMultipeerConnectivityController]startAdvertising];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
