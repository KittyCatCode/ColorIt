//
//  ViewController.m
//  Color It!
//
//  Created by Gabriel Pulido on 9/3/16.
//  Copyright © 2016 Gabriel Pulido. All rights reserved.
//

#import "ViewController.h"
#import "ColorPicker.h"
#import "DrawingScene.h"
@interface ViewController ()
@property CGFloat brushSize;
@property DrawingScene* scene;
@property BOOL hasInit;
@end
@implementation ViewController
- (IBAction)open:(id)sender {
    [AQPhotoPickerView presentInViewController:self];
}
-(void)photoFromImagePickerView:(UIImage *)photo {
    //reset dialog
    //[self.drawing reset];
    //self.drawing.bg=photo;
}
- (IBAction)reset:(id)sender {
}
- (IBAction)save:(id)sender {
}
- (IBAction)noColor:(id)sender {
    self.scene.dontDraw=(self.scene.dontDraw?NO:YES);
    self.nocolor.tintColor=(self.scene.dontDraw?[UIColor greenColor]:[UIColor blackColor]);
    self.nocolor.title=(self.scene.dontDraw?@"Color":@"No Color");
}
- (IBAction)eraser:(id)sender {
    self.satSlider.value=0;
    [self satValueChanged:nil];
}

- (void)viewDidLoad {
    self.colorPicker.hue=0;
    [super viewDidLoad];
    //red
    self.hue.image=[ViewController imageWithColor:[UIColor colorWithHue:self.colorPicker.hue saturation:1 brightness:1 alpha:1]];
    self.sat.image=[ViewController imageWithColor:[UIColor colorWithHue:self.colorPicker.hue saturation:self.satSlider.value brightness:1 alpha:1]];
    self.brushSize=0.5f;
    [self updateBrushImage];
    self.scene.brushSize=22;
    self.scene.hue=0;
    self.scene.sat=1;
}
-(void)viewDidLayoutSubviews {
    self.scene.brushSize=self.brushSlider.value*self.brush.frame.size.width;
    if(self.hasInit)return;
    self.hasInit=YES;
    DrawingScene* scene = [[DrawingScene alloc] initWithSize:self.drawingView.frame.size];
    scene.c=self;
    scene.scaleMode=SKSceneScaleModeResizeFill;
    scene.bg=[UIImage imageNamed:@"cat-wallpaper-15.jpg"];
    self.scene=scene;
    [((SKView*)self.drawingView) presentScene:scene];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)satValueChanged:(id)sender {
    self.sat.image=[ViewController imageWithColor:[UIColor colorWithHue:self.colorPicker.hue saturation:self.satSlider.value brightness:1 alpha:1]];
    //self.drawing.sat=self.satSlider.value;
}

- (IBAction)brushValueChanged:(id)sender {
    [self updateBrushImage];
    //self.drawing.brushSize=self.brushSlider.value*self.brush.frame.size.width;
}
- (IBAction)colorValueChanged:(id)sender {
    self.hue.image=[ViewController imageWithColor:[UIColor colorWithHue:self.colorPicker.hue saturation:1 brightness:1 alpha:1]];
    self.sat.image=[ViewController imageWithColor:[UIColor colorWithHue:self.colorPicker.hue saturation:self.satSlider.value brightness:1 alpha:1]];
    //self.drawing.hue=self.colorPicker.hue;
}
-(void)updateBrushImage {
    self.brushSize=self.brushSlider.value;
    //First get a context for the new brush image.
    CGRect rect = CGRectMake(0.0f, 0.0f, 100.0f, 100.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Draw a filled circle.
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(50-(self.brushSize*50), 50-(self.brushSize*50), self.brushSize*100, self.brushSize*100));
    //Get image and close context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //Set brush image to image.
    self.brush.image=image;
}
- (IBAction)resetDrawing:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete?" message:@"Are you sure you want to delete your drawing?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //[self.drawing reset];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    //gato <#:3#>
}
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
