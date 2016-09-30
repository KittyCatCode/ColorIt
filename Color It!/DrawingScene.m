//
//  DrawingScene.m
//  Color It!
//
//  Created by Gabriel Pulido on 9/30/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import "DrawingScene.h"
@interface DrawingScene ()
@property BOOL hasInit;
@end
@implementation DrawingScene
-(void)didMoveToView:(SKView *)view {
    if(!self.hasInit) {
        [self createContents];
        self.hasInit=YES;
    }
}
-(void)createContents {
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
@end
