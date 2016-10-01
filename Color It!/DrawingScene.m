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
@property SKNode* bgNodeContainer;
@property SKNode* finalizedDrawingContainer;
@property SKNode* drawingContainer;
@property SKSpriteNode* finalized;
@property SKNode* all;
@property NSMutableArray<UITouch*>* allTouches;
@property CGPoint initialPoint1;
@property CGPoint initialPoint2;
///
@end
@implementation DrawingScene
-(void)didMoveToView:(SKView *)view {
    if(!self.hasInit) {
        [self createContents];
        self.hasInit=YES;
    }
}
-(void)createContents {
    self.anchorPoint=CGPointMake(0.5, 0.5);
    self.all=[SKNode new];
    self.backgroundColor=[UIColor whiteColor];
    self.bgNodeContainer=[SKNode new];
    self.finalizedDrawingContainer=[SKNode new];
    self.finalized=[SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeZero];
    [self.finalizedDrawingContainer addChild:self.finalized];
    self.drawingContainer=[SKNode new];
    [self.all addChild:self.finalizedDrawingContainer];
    [self.all addChild:self.drawingContainer];
    [self.all addChild:self.bgNodeContainer];
    [self addChild:self.all];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(!self.allTouches)self.allTouches=[NSMutableArray new];
    int oldTouches=(int)self.allTouches.count;
    [self.allTouches addObjectsFromArray:touches.allObjects];
    NSMutableArray<UITouch*>* toRemove=[NSMutableArray new];
    [self.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.phase==UITouchPhaseEnded) {
            [toRemove addObject:obj];
        }
    }];
    [self.allTouches removeObjectsInArray:toRemove];
    int newTouches=(int)self.allTouches.count;
    if(oldTouches!=newTouches) {
        [self transitionFrom:oldTouches to:newTouches with:self.allTouches];
    }
    [self handleMovementWith:self.allTouches];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    int oldTouches=(int)self.allTouches.count;
    NSMutableArray<UITouch*>* toRemove=[NSMutableArray new];
    [self.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.phase==UITouchPhaseEnded) {
            [toRemove addObject:obj];
        }
    }];
    [self.allTouches removeObjectsInArray:toRemove];
    int newTouches=(int)self.allTouches.count;
    if(newTouches!=oldTouches) {
        [self transitionFrom:oldTouches to:newTouches with:self.allTouches];
    }
    [self handleMovementWith:self.allTouches];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    int oldTouches=(int)self.allTouches.count;
    [self.allTouches removeObjectsInArray:touches.allObjects];
    int newTouches=(int)self.allTouches.count;
    [self transitionFrom:oldTouches to:newTouches with:self.allTouches];
    [self handleMovementWith:self.allTouches];
}
-(void)transitionFrom:(int)oldTouches to:(int)newTouches with:(NSArray<UITouch*>*)touches {
    if(newTouches==2) {
        self.initialPoint1=[touches.firstObject locationInNode:self];
        self.initialPoint2=[touches.lastObject locationInNode:self];
    }
}
-(void)handleMovementWith:(NSArray<UITouch*>*)touches {
    if(touches.count==2) {
        CGPoint first=[touches.firstObject locationInNode:self];
        CGPoint second=[touches.lastObject locationInNode:self];
        CGPoint initCenter=[self pointByCenter:self.initialPoint1 and:self.initialPoint2];
        CGPoint currCenter=[self pointByCenter:first and:second];
        self.all.position=[self pointByAddingPoints:self.all.position and:[self pointBySubtractingPoints:initCenter from:currCenter]];
        CGFloat scaleBy=[self floatByDistanceFrom:first and:second]/[self floatByDistanceFrom:self.initialPoint1 and:self.initialPoint2];
        CGPoint oldPositionRelativeToCenter=[self pointBySubtractingPoints:currCenter from:self.all.position];
        self.all.xScale*=scaleBy;
        self.all.yScale*=scaleBy;
        self.all.position=[self pointByAddingPoints:currCenter and:[self pointByScalingPoint:oldPositionRelativeToCenter by:scaleBy]];
        CGFloat rotateBy=atan2(second.y-first.y,second.x-first.x)-atan2(self.initialPoint2.y-self.initialPoint1.y, self.initialPoint2.x-self.initialPoint1.x);
        self.all.zRotation+=rotateBy;
        //rotate position around currCenter
        //get distance and rotation
        CGFloat distance = [self floatByDistanceFrom:self.all.position and:currCenter];
        CGPoint toAtan = [self pointBySubtractingPoints:currCenter from:self.all.position];
        CGFloat rotation = atan2(toAtan.y,toAtan.x);
        //add to rotation
        rotation+=rotateBy;
        //recalculate
        self.all.position=[self pointByAddingPoints:currCenter and:[self pointByScalingPoint:CGPointMake(cos(rotation), sin(rotation)) by:distance]];
        self.initialPoint1=first;
        self.initialPoint2=second;
    }
}
-(CGPoint)pointBySubtractingPoints:(CGPoint)a from:(CGPoint)b {
    return CGPointMake(b.x-a.x, b.y-a.y);
}
-(CGPoint)pointByAddingPoints:(CGPoint)a and:(CGPoint)b {
    return CGPointMake(a.x+b.x, a.y+b.y);
}
-(CGPoint)pointByCenter:(CGPoint)a and:(CGPoint)b {
    return CGPointMake((a.x+b.x)/2,(a.y+b.y)/2);
}
-(CGFloat)floatByDistanceFrom:(CGPoint)a and:(CGPoint)b {
    return sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
}
-(CGPoint)pointByScalingPoint:(CGPoint)a by:(CGFloat)b {
    return CGPointMake(a.x*b, a.y*b);
}
-(void)setBg:(UIImage*)a {
    if(!self.hasInit){[self createContents];self.hasInit=YES;}
    [self.bgNodeContainer removeAllChildren];
    [self.drawingContainer removeAllChildren];
    [self.bgNodeContainer addChild:[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:a] size:a.size]];
    UIGraphicsBeginImageContext(a.size);
    self.finalized.texture=[SKTexture textureWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    self.finalized.size=a.size;
    CGFloat scaleFitWidth=self.size.width/a.size.width;
    CGFloat scaleFitHeight=self.size.height/a.size.height;
    if(scaleFitWidth>scaleFitHeight) {
        self.all.xScale=scaleFitWidth;
        self.all.yScale=scaleFitWidth;
    } else {
        self.all.xScale=scaleFitHeight;
        self.all.yScale=scaleFitHeight;
    }
}
-(UIImage*)getBg {
    [NSException raise:NSInternalInconsistencyException
                              format:@"property is write-only"];
    return nil;
}
-(void)didChangeSize:(CGSize)oldSize {
    self.all.position=CGPointZero;
    self.all.zRotation=0;
    CGFloat scaleFitWidth=self.size.width/self.all.calculateAccumulatedFrame.size.width;
    CGFloat scaleFitHeight=self.size.height/self.all.calculateAccumulatedFrame.size.height;
    if(scaleFitWidth>scaleFitHeight) {
        self.all.xScale*=scaleFitWidth;
        self.all.yScale*=scaleFitWidth;
    } else {
        self.all.xScale*=scaleFitHeight;
        self.all.yScale*=scaleFitHeight;
    }
}
@end
