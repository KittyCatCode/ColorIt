//
//  DrawingScene.m
//  Color It!
//
//  Created by Gabriel Pulido on 9/30/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import "DrawingScene.h"
#import "PathElement.h"
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
@property BOOL shouldDraw;
@property UIImage* finalizedImage;
@property NSMutableArray<PathElement*>* drawingSteps;
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
    self.drawingSteps=[NSMutableArray new];
    self.shouldDraw=YES;
    self.anchorPoint=CGPointMake(0.5, 0.5);
    self.all=[SKNode new];
    self.backgroundColor=[UIColor whiteColor];
    self.bgNodeContainer=[SKNode new];
    self.finalizedDrawingContainer=[SKNode new];
    self.finalizedImage=[UIImage imageNamed:@"empty.png"];
    self.finalized=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:self.finalizedImage] size:CGSizeZero];
    if(self.size.width>self.size.height) {
        self.finalized.size=CGSizeMake(self.size.width, self.size.width);
    } else {
        self.finalized.size=CGSizeMake(self.size.height, self.size.height);
    }
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
    [self handleMovementWith:self.allTouches first:YES];
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
    [self handleMovementWith:self.allTouches first:NO];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    int oldTouches=(int)self.allTouches.count;
    [self.allTouches removeObjectsInArray:touches.allObjects];
    int newTouches=(int)self.allTouches.count;
    [self transitionFrom:oldTouches to:newTouches with:self.allTouches];
    [self handleMovementWith:self.allTouches first:NO];
}
-(CGFloat)getRealBrushSize{
    return [self floatByDistanceFrom:[self.all convertPoint:CGPointZero fromNode:self] and:[self.all convertPoint:CGPointMake(0, 1) fromNode:self]]*self.brushSize;
}
-(void)transitionFrom:(int)oldTouches to:(int)newTouches with:(NSArray<UITouch*>*)touches {
    if(oldTouches==1) {
        if(newTouches>1) {
            self.shouldDraw=NO;
            [self.drawingContainer removeAllChildren];
            [self.drawingSteps removeAllObjects];
        } else {
            UIGraphicsBeginImageContext(self.finalizedImage.size);
            [self.finalizedImage drawAtPoint:CGPointZero];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGMutablePathRef path = CGPathCreateMutable();
            //Now draw the line.
            __block CGPoint last;
            __block BOOL started=NO;
            [self.drawingSteps enumerateObjectsUsingBlock:^(PathElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.point=CGPointMake(obj.point.x+(0.5*self.finalizedImage.size.width), -obj.point.y+(0.5*self.finalizedImage.size.height));
                if(!started) {
                    CGPathMoveToPoint(path, NULL, obj.point.x, obj.point.y);
                } else {
                    CGPathAddLineToPoint(path, NULL, obj.point.x, obj.point.y);
                }
                last=obj.point;
                started=YES;
            }];
            //CGPathCloseSubpath(path);
            CGFloat bs = self.drawingSteps.firstObject.size;
            CGContextSetLineWidth(context, bs);
            CGContextAddPath(context, path);
            [[UIColor colorWithHue:self.hue saturation:self.sat brightness:1 alpha:1] setStroke];
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextStrokePath(context);
            [[UIColor colorWithHue:self.hue saturation:self.sat brightness:1 alpha:1] setFill];
            CGContextFillEllipseInRect(context, CGRectMake(self.drawingSteps.firstObject.point.x-(bs/2), self.drawingSteps.firstObject.point.y-(bs/2), bs, bs));
            CGContextFillEllipseInRect(context, CGRectMake(self.drawingSteps.lastObject.point.x-(bs/2), self.drawingSteps.lastObject.point.y-(bs/2), bs, bs));
            self.finalizedImage=UIGraphicsGetImageFromCurrentImageContext();
            self.finalized.texture=[SKTexture textureWithImage:self.finalizedImage];
            CGPathRelease(path);
            UIGraphicsEndImageContext();
            [self.drawingContainer removeAllChildren];
            [self.drawingSteps removeAllObjects];
        }
    }
    if(newTouches==0) {
        self.shouldDraw=YES;
    }
    if(newTouches==1&&self.shouldDraw&&!self.dontDraw) {
        self.initialPoint1=[touches.firstObject locationInNode:self.all];
        CGFloat real = [self getRealBrushSize];
        SKShapeNode* child = [SKShapeNode shapeNodeWithEllipseOfSize:CGSizeMake(real, real)];
        child.fillColor=[UIColor colorWithHue:self.hue saturation:self.sat brightness:1 alpha:1];
        child.strokeColor=child.fillColor;
        child.position=self.initialPoint1;
        [self.drawingContainer addChild:child];
        PathElement* e = [PathElement new];
        e.point=self.initialPoint1;
        e.size=real;
        [self.drawingSteps addObject:e];
    }
    if(newTouches==2) {
        self.initialPoint1=[touches.firstObject locationInNode:self];
        self.initialPoint2=[touches.lastObject locationInNode:self];
    }
}
-(void)handleMovementWith:(NSArray<UITouch*>*)touches first:(BOOL)first{
    if(touches.count==1&&!first&&self.shouldDraw&&!self.dontDraw) {
        CGPoint first=[touches.firstObject locationInNode:self.all];
        CGFloat real = [self getRealBrushSize];
        UIColor* color=[UIColor colorWithHue:self.hue saturation:self.sat brightness:1 alpha:1];
        SKShapeNode* child = [SKShapeNode shapeNodeWithEllipseOfSize:CGSizeMake(real, real)];
        child.fillColor=color;
        child.strokeColor=child.fillColor;
        child.position=self.initialPoint1;
        SKShapeNode* child2 = [SKShapeNode shapeNodeWithEllipseOfSize:CGSizeMake(real, real)];
        child2.fillColor=color;
        child2.strokeColor=child2.fillColor;
        child2.position=first;
        [self.drawingContainer addChild:child2];
        CGFloat distance = [self floatByDistanceFrom:self.initialPoint1 and:first];
        SKSpriteNode* stroke = [SKSpriteNode spriteNodeWithColor:color size:CGSizeMake(distance, real)];
        CGFloat rotation=atan2(first.y-self.initialPoint1.y,first.x-self.initialPoint1.x);
        stroke.zRotation=rotation;
        stroke.position=[self pointByCenter:first and:self.initialPoint1];
        [self.drawingContainer addChild:stroke];
        PathElement* e = [PathElement new];
        e.point=first;
        e.size=real;
        [self.drawingSteps addObject:e];
        self.initialPoint1=first;
    }
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
}- (UIImage *)convertImageToGrayScale:(UIImage *)image {
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
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
    NSLog(@"%f,%f",a.size.width,a.size.height);
    a=[self convertImageToGrayScale:a];
    if(!self.hasInit){[self createContents];self.hasInit=YES;}
    [self.drawingSteps removeAllObjects];
    [self.bgNodeContainer removeAllChildren];
    [self.drawingContainer removeAllChildren];
    SKSpriteNode* imageNode=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:a] size:a.size];
    imageNode.blendMode=SKBlendModeMultiply;
    [self.bgNodeContainer addChild:imageNode];
    UIGraphicsBeginImageContext(a.size);
    self.finalizedImage=UIGraphicsGetImageFromCurrentImageContext();
    self.finalized.texture=[SKTexture textureWithImage:self.finalizedImage];
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
    self.all.position=CGPointZero;
    self.all.zRotation=0;
}
-(void)reset {
    UIGraphicsBeginImageContext(self.finalized.size);
    self.finalized.texture=[SKTexture textureWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    [self.drawingContainer removeAllChildren];
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
