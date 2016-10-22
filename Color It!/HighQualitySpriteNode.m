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
-(BOOL)doesPolygon:(CGPoint*)a withLen:(int)alen intersectWith:(CGPoint*)b withLen:(int)blen{//cgpoint value
    if(!a||!b)return NO;
    __block BOOL shouldReturnFalse=false;
    for(int i=0;i<2;i++){
        CGPoint* polygon=(i==0?a:b);
        int polypointcount=(i==0?alen:blen);
        for (int i1 = 0; i1 < polypointcount; i1++)
        {
            int i2 = (i1 + 1) % polypointcount;
            CGPoint p1 = polygon[i1];
            CGPoint p2 = polygon[i2];
            
            CGPoint normal = CGPointMake(p2.y - p1.y, p2.x - p1.x);
            
            __block NSNumber* minA = nil;//cgfloat value
            __block NSNumber* maxA = nil;//cgfloat value
            for(int i=0;i<alen;i++) {
                CGFloat projected = normal.x * a[i].x + normal.y * a[i].y;
                if (minA == nil || projected < minA.doubleValue)
                    minA=[NSNumber numberWithDouble:projected];
                if (maxA == nil || projected > maxA.doubleValue)
                    maxA=[NSNumber numberWithDouble:projected];
            }
            __block NSNumber* minB = nil;
            __block NSNumber* maxB = nil;
            for(int i=0;i<blen;i++){
                double projected = normal.x * b[i].x + normal.y * b[i].y;
                if (minB == nil || projected < minB.doubleValue)
                    minB = [NSNumber numberWithDouble:projected];
                if (maxB == nil || projected > maxB.doubleValue)
                    maxB = [NSNumber numberWithDouble:projected];
            }
            
            shouldReturnFalse|=maxA.doubleValue < minB.doubleValue || maxB.doubleValue < minA.doubleValue;
        }
    }
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
            CGPoint last=CGPointZero;
            if(lastElement) {
                last=CGPointMake(((lastElement.point.x+(self.wid/2.0))+offX-(self.s*(idx%self.swid))),(((self.hei/2.0)-lastElement.point.y)-offY)-(self.s*(idx/self.swid)));
            }
            CGPoint curr=CGPointMake(((ele.point.x+(self.wid/2.0))+offX-(self.s*(idx%self.swid))),(((self.hei/2.0)-ele.point.y)-offY)-(self.s*(idx/self.swid)));
            CGPoint* segPoly =(CGPoint[4]){CGPointMake(0, 0),CGPointMake(0, self.s),CGPointMake(self.s, self.s),CGPointMake(self.s,0)};
            CGPoint* linePoly = nil;
            if(lastElement) {
                //define linePoly
                CGFloat a=ele.point.x-lastElement.point.x;
                CGFloat b=ele.point.y-lastElement.point.y;
                CGFloat xOff=(a/sqrt(a*a+b*b))*(ele.size/2);
                CGFloat yOff=(b/sqrt(a*a+b*b))*(ele.size/2);
                linePoly=(CGPoint[4]){CGPointMake(last.x-xOff, last.y-yOff),CGPointMake(last.x+xOff, last.y+yOff),CGPointMake(curr.x+xOff, curr.y+yOff),CGPointMake(curr.x-xOff, curr.y-yOff)};
            }
            NSLog(@"%f,%f",curr.x,curr.y);
            bool circ=[self doesCircle:curr withRadius:ele.size intersectRect:CGRectMake(0, 0, self.s, self.s)];
            bool poly=[self doesPolygon:linePoly withLen:4 intersectWith:segPoly withLen:4];
            if(circ||poly) {
                //draw
                UIGraphicsBeginImageContext(CGSizeMake(self.s, self.s));
                [self.internalImages[idx] drawAtPoint:CGPointMake(0, 0)];
                [c setFill];
                [c setStroke];
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextFillEllipseInRect(context, CGRectMake(curr.x-(ele.size/2), curr.y-(ele.size/2), ele.size, ele.size));
                if(lastElement) {
                    CGContextSetLineWidth(context, ele.size);
                    CGContextStrokeLineSegments(context, (CGPoint[2]){last,curr}, 2);
                }
                self.internalImages[idx]=UIGraphicsGetImageFromCurrentImageContext();
                obj.texture=[SKTexture textureWithImage:self.internalImages[idx]];
                UIGraphicsEndImageContext();
            }
            lastElement=ele;
        }];
    }];
}
@end
