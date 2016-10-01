//
//  AQPhotoPickerVC.h
//  MeeFree.com
//
//  Created by Abdul_Qavi on 14/09/2014.
//  Copyright (c) 2014 MeeFree.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AQPhotoPicker;
@protocol AQPhotoPickerDelegate
-(void)photoFromImagePicker:(UIImage*)photo;
@end

@interface AQPhotoPicker : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+(void)presentInViewController:(UIViewController<AQPhotoPickerDelegate>*) viewController;

- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;

@end
