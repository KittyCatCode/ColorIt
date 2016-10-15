//
//  HighQualitySpriteNode.m
//  Color It!
//
//  Created by Gabriel Pulido on 10/12/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import "HighQualitySpriteNode.h"
#import "PathElement.h"
@interface HighQualitySpriteNode ()
@property NSMutableArray<UIImage*>* internalImages;
@property int wid;
@property int hei;
@property int swid;
@property int shei;
@property long bm;
@property int s;
@property NSArray<SKSpriteNode*>* nodes;
@end
@implementation HighQualitySpriteNode
+(instancetype)newWithImage:(UIImage *)im segmentSize:(int)s {
    HighQualitySpriteNode* ret = [self new];
    ret.s=s;
    NSMutableArray<UIImage*>* images = [NSMutableArray new];
    ret.internalImages=images;
    ret.wid=im.size.width;
    ret.hei=im.size.height;
    int widthInSegments = ((int)im.size.width/s)+((((int)im.size.width)/s)!=(im.size.width/s)?2:0);
    int heightInSegments = ((int)im.size.height/s)+((((int)im.size.height)/s)!=(im.size.height/s)?2:0);
    ret.swid=widthInSegments;
    ret.shei=heightInSegments;
    CGFloat offX=(widthInSegments*s-im.size.width)/2;
    CGFloat offY=(heightInSegments*s-im.size.height)/2;
    for(int y=0;y<heightInSegments;y++) {
        for(int x=0;x<widthInSegments;x++) {
            UIGraphicsBeginImageContext(CGSizeMake(s, s));
            [im drawAtPoint:CGPointMake((-x*s)+offX, (-y*s)+offY)];
            [images addObject:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
    }
    NSMutableArray* nodes=[NSMutableArray new];
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SKSpriteNode* render = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:obj] size:CGSizeMake(s, s)];
        render.position=CGPointMake((-(im.size.width/2)+((idx%widthInSegments)*s))-(s/2.0)+(s-offX), ((im.size.height/2)-((idx/widthInSegments)*s))+(s/2.0)-(s-offY));
        [nodes addObject:render];
        [ret addChild:render];
    }];
    ret.nodes=nodes;
    return ret;
}
-(NSArray<UIImage*>*)getImages {
    return self.internalImages;
}
-(int)getImageWidth {
    return self.wid;
}
-(int)getImageHeight {
    return self.hei;
}
-(void)setBlendMode:(long)blendMode {
    self.bm=blendMode;
    [self.nodes enumerateObjectsUsingBlock:^(SKSpriteNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.blendMode=blendMode;
    }];
}
-(long)blendMode {
    return self.bm;
}
-(void)setImage:(UIImage *)i forX:(int)x andY:(int)y {
    self.nodes[y*self.swid+x].texture=[SKTexture textureWithImage:i];
    self.internalImages[y*self.swid]=i;
}
-(CGFloat)clamp:(CGFloat)o min:(CGFloat)a max:(CGFloat)b {
    if(o<a) {
        return a;
    } else if(o>b) {
        return b;
    } else {
        return o;
    }
}
-(CGPoint)closestPoint:(CGPoint)p rect:(CGRect)r {
    return CGPointMake([self clamp:p.x min:r.origin.x max:r.origin.x+r.size.width], [self clamp:p.y min:r.origin.y max:r.origin.y+r.size.height]);
}
-(BOOL)doesCircle:(CGPoint)center withRadius:(CGFloat)radius intersectRect:(CGRect)r {
    CGPoint cp = [self closestPoint:center rect:r];
    CGFloat xd = center.x-cp.x;
    CGFloat yd = center.y-cp.y;
    return (radius*radius)>(xd*xd+yd*yd);
}
-(BOOL)doesPolygon:(NSArray<NSValue*>*)a intersectWith:(NSArray<NSValue*>*)b{//cgpoint value
    if(!a||!b)return NO;
    __block BOOL shouldReturnFalse=false;
    [@[a,b] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSValue*>* polygon=obj;
        for (int i1 = 0; i1 < polygon.count; i1++)
        {
            int i2 = (i1 + 1) % polygon.count;
            CGPoint p1 = polygon[i1].CGPointValue;
            CGPoint p2 = polygon[i2].CGPointValue;
            
            CGPoint normal = CGPointMake(p2.y - p1.y, p1.x - p2.x);
            
            __block NSNumber* minA = nil;//cgfloat value
            __block NSNumber* maxA = nil;//cgfloat value
            [a enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat projected = normal.x * obj.CGPointValue.x + normal.y * obj.CGPointValue.y;
                if (minA == nil || projected < minA.doubleValue)
                    minA=[NSNumber numberWithDouble:projected];
                if (maxA == nil || projected > maxA.doubleValue)
                    maxA=[NSNumber numberWithDouble:projected];
            }];
            __block NSNumber* minB = nil;
            __block NSNumber* maxB = nil;
            [b enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                double projected = normal.x * obj.CGPointValue.x + normal.y * obj.CGPointValue.y;
                if (minB == nil || projected < minB.doubleValue)
                    minB = [NSNumber numberWithDouble:projected];
                if (maxB == nil || projected > maxB.doubleValue)
                    maxB = [NSNumber numberWithDouble:projected];
            }];
            
            shouldReturnFalse|=maxA.doubleValue < minB.doubleValue || maxB.doubleValue < minA.doubleValue;
        }
    }];
    return !shouldReturnFalse;
}
-(void)drawPath:(NSArray<PathElement *> *)path withColor:(UIColor*)c {
    __block PathElement* lastElement=nil;
    [path enumerateObjectsUsingBlock:^(PathElement * _Nonnull ele, NSUInteger idx, BOOL * _Nonnull stop) {
        //<#gatos#>
        CGFloat offX=(self.swid*self.s-self.wid)/2;
        CGFloat offY=(self.shei*self.s-self.hei)/2;
        [self.nodes enumerateObjectsUsingBlock:^(SKSpriteNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //convert pathelement to seg coords.
            CGPoint last;
            if(lastElement) {
                last=CGPointMake(fmod(lastElement.point.x+offX,self.s),fmod(lastElement.point.y-offY,self.s));
            }
            CGPoint curr=CGPointMake(fmod(ele.point.x+offX,self.s),fmod(ele.point.y-offY,self.s));
            NSArray<NSValue*>* segPoly =@[[NSValue valueWithCGPoint:CGPointMake(0, 0)],[NSValue valueWithCGPoint:CGPointMake(0, self.s)],[NSValue valueWithCGPoint:CGPointMake(self.s, self.s)],[NSValue valueWithCGPoint:CGPointMake(self.s,0)]];
            NSArray<NSValue*>* linePoly = nil;
            if(lastElement) {
                //define linePoly
                CGFloat a=ele.point.x-lastElement.point.x;
                CGFloat b=ele.point.y-lastElement.point.y;
                CGFloat xOff=(a/sqrt(a*a+b*b))*(ele.size/2);
                CGFloat yOff=(b/sqrt(a*a+b*b))*(ele.size/2);
                linePoly=@[[NSValue valueWithCGPoint:CGPointMake(lastElement.point.x-xOff, lastElement.point.y-yOff)],[NSValue valueWithCGPoint:CGPointMake(lastElement.point.x+xOff, lastElement.point.y+yOff)],[NSValue valueWithCGPoint:CGPointMake(ele.point.x+xOff, ele.point.y+yOff)],[NSValue valueWithCGPoint:CGPointMake(ele.point.x-xOff,ele.point.y-yOff)]];
            }
            if([self doesCircle:curr withRadius:ele.size intersectRect:CGRectMake(0, 0, self.s, self.s)]||[self doesPolygon:segPoly intersectWith:linePoly]) {
                //draw
                UIGraphicsBeginImageContext(CGSizeMake(self.s, self.s));
                [self.internalImages[idx] drawAtPoint:CGPointMake(0, 0)];
                [c setFill];
                [c setStroke];
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextFillEllipseInRect(context, CGRectMake(ele.point.x-(ele.size/2), ele.point.y-(ele.size/2), ele.size, ele.size));
                if(lastElement) {
                    CGContextSetLineWidth(context, ele.size);
                    CGContextStrokeLineSegments(context, (CGPoint[2]){lastElement.point,ele.point}, 2);
                }
                obj.texture=[SKTexture textureWithImage:UIGraphicsGetImageFromCurrentImageContext()];
                UIGraphicsEndImageContext();
            }
            lastElement=ele;
        }];
    }];
}
@end
