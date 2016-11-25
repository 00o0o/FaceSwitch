//
//  UISwitch+ZMAdd.h
//  ram-test
//
//  Created by Clover on 11/25/16.
//  Copyright © 2016 Clover. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ValueChangedHandler)(BOOL);

@interface UISwitch (ZMAdd)

@property (nonatomic, strong) UIColor *faceColor;
@property (nonatomic, strong) ValueChangedHandler valueChangedHandler;
@end
