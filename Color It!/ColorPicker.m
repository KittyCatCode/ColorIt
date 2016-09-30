//
//  ColorPicker.m
//  Color It!
//
//  Created by Gabriel Pulido on 9/3/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import "ColorPicker.h"

@implementation ColorPicker

///*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGFloat l[7]={0,1/(CGFloat)6,2/(CGFloat)6,3/(CGFloat)6,4/(CGFloat)6,5/(CGFloat)6,1};
    CGGradientRef g = CGGradientCreateWithColors(cs, (__bridge CFArrayRef)@[(id)[UIColor redColor].CGColor,(id)[UIColor yellowColor].CGColor,(id)[UIColor greenColor].CGColor,(id)[UIColor cyanColor].CGColor,(id)[UIColor blueColor].CGColor,(id)[UIColor magentaColor].CGColor, (id)[UIColor redColor].CGColor],l);
    CGContextDrawLinearGradient(c, g, CGPointMake(0, self.frame.size.height/2),CGPointMake(self.frame.size.width, self.frame.size.height/2),0);
    CGGradientRelease(g);
    CGColorSpaceRelease(cs);
}
//*/
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* first = touches.allObjects.firstObject;
    [self handleTouch:first];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* first = touches.allObjects.firstObject;
    [self handleTouch:first];
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* first = touches.allObjects.firstObject;
    [self handleTouch:first];
    
}
-(void)handleTouch:(UITouch*)t {
    CGFloat location = [t locationInView:self].x/self.frame.size.width;
    if(self.hue!=MIN(MAX(0,location),1)) {
        self.hue=MIN(MAX(0,location),1);
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}
@end
