//
//  ViewController.m
//  FaceSwitch
//
//  Created by Clover on 11/25/16.
//  Copyright © 2016 Clover. All rights reserved.
//

#import "ViewController.h"
#import "UISwitch+ZMAdd.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switch_;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.switch_.on = YES;
    self.switch_.faceColor = [UIColor redColor];
    self.switch_.valueChangedHandler = ^(BOOL on){
        NSLog(@"switch_: %d", on);
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
