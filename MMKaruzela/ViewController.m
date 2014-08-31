//
//  ViewController.m
//  MMKaruzela
//
//  Created by Michał Moskała on 29.08.2014.
//  Copyright (c) 2014 Miquido. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) BOOL forward;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.forward = YES;
}

- (void)viewWillLayoutSubviews {
    [self.segmentedControl updateConstraints];
}

@end
