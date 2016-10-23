//
//  DrawingScene.h
//  Color It!
//
//  Created by Gabriel Pulido on 9/30/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "ViewController.h"
@interface DrawingScene : SKScene
@property ViewController* c;
@property IBInspectable (getter=getBg,setter=setBg:) UIImage* bg;
@property IBInspectable CGFloat hue;
@property IBInspectable CGFloat sat;
@property IBInspectable CGFloat brushSize;
@property IBInspectable BOOL dontDraw;
-(UIImage*)getFinishedImage;
@property BOOL hasBeenModified;
-(void)reset;
@end
