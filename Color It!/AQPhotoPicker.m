//
//  AQPhotoPickerVC.m
//  MeeFree.com
//
//  Created by Abdul_Qavi on 14/09/2014.
//  Copyright (c) 2014 MeeFree.com. All rights reserved.
//

#import "AQPhotoPicker.h"
#import "ViewController.h"


@interface AQPhotoPicker ()

@property (nonatomic, weak) UIViewController <AQPhotoPickerDelegate> *delegateViewController;
@property (nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation AQPhotoPicker

+(void)presentInViewController:(UIViewController<AQPhotoPickerDelegate>*) viewController
{
    // Instantiating encapsulated here.
    __block AQPhotoPicker *picker = [AQPhotoPicker new];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Open Photo" message:@"Where would you like to open a photo?" preferredStyle:UIAlertControllerStyleActionSheet];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [picker takePhoto:nil];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [picker selectPhoto:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    // Pass in a reference of the viewController.
    picker.delegateViewController = viewController;
    [viewController presentViewController:alert animated:YES completion:^{
        
    }];
}

#pragma mark - Image capture and picker methods

- (void)selectPhoto:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.delegateViewController presentViewController:picker animated:YES completion:nil];
}

- (void)takePhoto:(id)sender {

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"Test on real device, camera is not available in simulator" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self.delegateViewController presentViewController:picker animated:YES completion:nil];
    [self.imagePickerController takePicture];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self.delegateViewController photoFromImagePicker:chosenImage];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
