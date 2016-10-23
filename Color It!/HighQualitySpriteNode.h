//
//  HighQualitySpriteNode.h
//  Color It!
//
//  Created by Gabriel Pulido on 10/12/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class PathElement;
@interface HighQualitySpriteNode : SKNode
+(instancetype)newWithImage:(UIImage*)i segmentSize:(int)s;//check
@property (readonly,getter=getImages) NSArray<UIImage*>* images;//check
@property (readonly,getter=getImageWidth) int imageWidth;//check
@property (readonly,getter=getImageHeight) int imageHeight;//check
@property long blendMode;//check
-(NSArray<UIImage*>*)getImages;//check
-(int)getImageWidth;//check
-(int)getImageHeight;//check
-(void)setImage:(UIImage*)i forX:(int)x andY:(int)y;
-(void)drawPath:(NSArray<PathElement *> *)path withColor:(UIColor*)c withAll:(SKNode*)all;
-(UIImage*)recreateImage;
@end
