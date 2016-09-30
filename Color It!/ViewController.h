//
//  ViewController.h
//  Color It!
//
//  Created by Gabriel Pulido on 9/3/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQPhotoPickerView.h"
#import <SpriteKit/SpriteKit.h>
@class TwoPanScrollView;
@class ColorPicker;
@interface ViewController: UIViewController <AQPhotoPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *hue;
@property (weak, nonatomic) IBOutlet UIImageView *sat;
@property (weak, nonatomic) IBOutlet UIImageView *brush;
- (IBAction)satValueChanged:(id)sender;
- (IBAction)brushValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *satSlider;
@property (weak, nonatomic) IBOutlet UISlider *brushSlider;
@property (weak, nonatomic) IBOutlet ColorPicker *colorPicker;
@property (weak, nonatomic) IBOutlet SKView *drawingView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nocolor;
@end

