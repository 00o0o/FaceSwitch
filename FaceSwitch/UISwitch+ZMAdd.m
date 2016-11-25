//
//  UISwitch+ZMAdd.m
//  ram-test
//
//  Created by Clover on 11/25/16.
//  Copyright © 2016 Clover. All rights reserved.
//

#import "UISwitch+ZMAdd.h"
#import <objc/runtime.h>

const char *imageViewKey;

static CGSize containerSize;

@implementation UISwitch (ZMAdd)

+ (void)load {
    [self swizzleWithOriginSelector:@selector(initWithFrame:) targetSelector:@selector(xx_initWithFrame:)];
    [self swizzleWithOriginSelector:@selector(awakeFromNib) targetSelector:@selector(xx_awakeFromNib)];
    [self swizzleWithOriginSelector:@selector(setOn:) targetSelector:@selector(xx_setOn:)];
}

+ (void)swizzleWithOriginSelector:(SEL)originSelector targetSelector:(SEL)targetSelector {
    Class cls = [self class];
    
    Method originMethod = class_getInstanceMethod(cls, originSelector);
    Method targetMethod = class_getInstanceMethod(cls, targetSelector);
    
    BOOL isAdded = class_addMethod(cls, originSelector, method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod));
    if(isAdded) {
        class_replaceMethod(cls, targetSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }else {
        method_exchangeImplementations(originMethod, targetMethod);
    }
}

- (instancetype)xx_initWithFrame:(CGRect)frame {
    UISwitch *switchObj = [self xx_initWithFrame:frame];
    if(switchObj) {
        UIImageView *imageView = (UIImageView *)switchObj.subviews.firstObject.subviews.lastObject;
        containerSize = imageView.frame.size;
        objc_setAssociatedObject(switchObj, imageViewKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [imageView.layer addSublayer:[self faceLayer]];
        
        [switchObj addTarget:switchObj action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return switchObj;
}

- (void)xx_awakeFromNib {
    [self xx_awakeFromNib];
    
    UIImageView *imageView = (UIImageView *)self.subviews.firstObject.subviews.lastObject;
    containerSize = imageView.frame.size;
    objc_setAssociatedObject(self, imageViewKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [imageView.layer addSublayer:[self faceLayer]];
    
    [self addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)xx_setOn:(BOOL)on {
    [self xx_setOn:on];
    [self valueChanged:self];
}

#pragma mark - Private methods
- (void)valueChanged:(UISwitch *)sender {
    UIImageView *imageView = (UIImageView *)objc_getAssociatedObject(self, imageViewKey);
    [imageView.layer.sublayers.lastObject removeFromSuperlayer];
    [imageView.layer addSublayer:[self faceLayer]];
    
    !self.valueChangedHandler ?: self.valueChangedHandler(sender.on);
}


- (CAShapeLayer *)faceLayer {
    UIBezierPath *eyePath = [UIBezierPath bezierPath];
    
    [eyePath addArcWithCenter:CGPointMake(22, 18) radius:2.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [eyePath addArcWithCenter:CGPointMake(35, 18) radius:2.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    CAShapeLayer *eyeLayer = [CAShapeLayer layer];
    if(self.faceColor) {
        eyeLayer.fillColor = self.faceColor.CGColor;
    }else {
        eyeLayer.fillColor = [UIColor blueColor].CGColor;
    }
    eyeLayer.path = eyePath.CGPath;
    
    UIBezierPath *mouthPath = [UIBezierPath bezierPath];
    if(self.on) {
        [mouthPath addArcWithCenter:CGPointMake(containerSize.width / 2, containerSize.height / 2 + 2) radius:6 startAngle:0 endAngle:M_PI clockwise:YES];
    }else {
        //[mouthPath moveToPoint:CGPointMake(22, containerSize.height / 2 + 6)];
        //[mouthPath addLineToPoint:CGPointMake(35, containerSize.height / 2 + 6)];
        [mouthPath addArcWithCenter:CGPointMake(containerSize.width / 2, containerSize.height / 2 + 9) radius:6 startAngle:0 endAngle:M_PI clockwise:NO];
    }
    
    CAShapeLayer *mouthLayer = [CAShapeLayer layer];
//    if(self.on) {
//        if(self.faceColor) {
//            mouthLayer.fillColor = self.faceColor.CGColor;
//        }else {
//            mouthLayer.fillColor = [UIColor blueColor].CGColor;
//        }
//    }else {
    mouthLayer.strokeStart = 0.15;
    mouthLayer.strokeEnd = 0.85;
        mouthLayer.lineWidth = 2;
        mouthLayer.lineCap = kCALineCapRound;
        mouthLayer.fillColor = [UIColor clearColor].CGColor;
        if(self.faceColor) {
            mouthLayer.strokeColor = self.faceColor.CGColor;
        }else {
            mouthLayer.strokeColor = [UIColor blueColor].CGColor;
        }
//    }
    mouthLayer.path = mouthPath.CGPath;
    
    [eyeLayer addSublayer:mouthLayer];
    
    return eyeLayer;
}

- (void)setFaceColor:(UIColor *)faceColor {
    objc_setAssociatedObject(self, @selector(faceColor), faceColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self valueChanged:self];
}

- (UIColor *)faceColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setValueChangedHandler:(ValueChangedHandler)valueChangedHandler {
    objc_setAssociatedObject(self, @selector(valueChangedHandler), valueChangedHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ValueChangedHandler)valueChangedHandler {
    return objc_getAssociatedObject(self, _cmd);
}

@end
