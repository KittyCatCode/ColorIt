//
//  HighQualitySpriteNode.m
//  Color It!
//
//  Created by Gabriel Pulido on 10/12/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import "HighQualitySpriteNode.h"
@interface HighQualitySpriteNode ()
@property NSMutableArray<UIImage*>* internalImages;
@property int wid;
@property int hei;
@property int swid;
@property int shei;
@property long bm;
@property NSArray<SKSpriteNode*>* nodes;
@end
@implementation HighQualitySpriteNode
+(instancetype)newWithImage:(UIImage *)im segmentSize:(int)s {
    HighQualitySpriteNode* ret = [self new];
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
-(BOOL)doesRect:(CGRect)r1 intersectRect:(CGRect)r2 {
    return CGRectIntersectsRect(r1, r2);
}
-(void)drawPath:(NSArray<PathElement *> *)path {
    [path enumerateObjectsUsingBlock:^(PathElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //<#gatos#>
        
    }];
}
@end
