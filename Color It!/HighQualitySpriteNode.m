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
            [[UIColor whiteColor] setFill];
            CGContextRef c = UIGraphicsGetCurrentContext();
            CGContextFillRect(c, CGRectMake(0, 0, s, s));
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
+(UIImage*)rotateCameraImageToProperOrientation:(UIImage*)imageSource {
    
    CGImageRef imgRef = imageSource.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation orient = imageSource.imageOrientation;
    CGSize imageSize = CGSizeMake(width,height);
    
    switch(imageSource.imageOrientation) {
        case UIImageOrientationUp :
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored :
            transform = CGAffineTransformMakeTranslation(imageSize.width,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationDown :
            transform = CGAffineTransformMakeTranslation(imageSize.width,imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored :
            transform = CGAffineTransformMakeTranslation(imageSize.width,0);
            transform = CGAffineTransformScale(transform, 1, -1);
            break;
        case UIImageOrientationLeft :
            {
                CGFloat storedHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = storedHeight;
                transform = CGAffineTransformMakeTranslation(0,imageSize.width);
                transform = CGAffineTransformRotate(transform,3.0 * M_PI / 2.0);
                break;
            }
        case UIImageOrientationLeftMirrored :
            {
                CGFloat storedHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = storedHeight;
                transform = CGAffineTransformMakeTranslation(imageSize.height,imageSize.width);
                transform = CGAffineTransformScale(transform,-1,1);
                transform = CGAffineTransformRotate(transform,3.0 * M_PI / 2.0);
                break;
            }
        case UIImageOrientationRight :
            {
                CGFloat storedHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = storedHeight;
                transform = CGAffineTransformMakeTranslation(imageSize.height, 0);
                transform = CGAffineTransformRotate(transform,M_PI / 2.0);
                break;
            }
        case UIImageOrientationRightMirrored :
            {
                CGFloat storedHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = storedHeight;
                transform = CGAffineTransformMakeScale(-1,1);
                transform = CGAffineTransformRotate(transform,M_PI / 2.0);
                break;
            }
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context,-1,1);
        CGContextTranslateCTM(context,-height,0);
    } else {
        CGContextScaleCTM(context,1,-1);
        CGContextTranslateCTM(context,0, -height);
    }
    
    CGContextConcatCTM(context,transform);
    CGContextDrawImage(context,CGRectMake(0, 0, width, height),imgRef);
    
    UIImage* imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
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
-(void)drawPath:(NSArray<PathElement *> *)path withColor:(UIColor*)c withAll:(SKNode*)all {
    __block CGMutablePathRef cgPath;
    __block CGFloat size;
    [self.nodes enumerateObjectsUsingBlock:^(SKSpriteNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
        cgPath=CGPathCreateMutable();
        __block CGPoint firstInPath;
        [path enumerateObjectsUsingBlock:^(PathElement * _Nonnull ele, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint inSegment=[obj convertPoint:ele.point fromNode:all];
            inSegment.x+=self.s/2.0;
            inSegment.y-=self.s/2.0;
            inSegment.y*=-1;
            if(idx==0) {
                CGPathMoveToPoint(cgPath, NULL, inSegment.x, inSegment.y);
                firstInPath=inSegment;
            } else {
                CGPathAddLineToPoint(cgPath,NULL,inSegment.x,inSegment.y);
            }
            size=ele.size;
        }];
        //draw
        UIGraphicsBeginImageContext(CGSizeMake(self.s, self.s));
        [self.internalImages[idx] drawAtPoint:CGPointMake(0, 0)];
        [c setFill];
        [c setStroke];
        CGContextRef context = UIGraphicsGetCurrentContext();
        if(path.count>1) {
            CGContextAddPath(context, cgPath);
            CGContextSetLineWidth(context, size);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextStrokePath(context);
        } else if(path.count==1) {
            CGContextFillEllipseInRect(context, CGRectMake(firstInPath.x-(size/2.0), firstInPath.y-(size/2.0), size, size));
        }
        self.internalImages[idx]=UIGraphicsGetImageFromCurrentImageContext();
        obj.texture=[SKTexture textureWithImage:self.internalImages[idx]];
        UIGraphicsEndImageContext();
        CGPathRelease(cgPath);
    }];
}
-(UIImage*)recreateImage {
    CGFloat offX=(self.swid*self.s-self.wid)/2;
    CGFloat offY=(self.shei*self.s-self.hei)/2;
    UIGraphicsBeginImageContext(CGSizeMake(self.wid,self.hei));
    [self.images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int sx=idx%self.swid;
        int sy=(int)(idx/self.swid);
        CGPoint renderImageAt =  CGPointMake(sx*self.s-offX, sy*self.s-offY);
        [obj drawAtPoint:renderImageAt];
    }];
    UIImage* toReturn=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return toReturn;
}
@end
