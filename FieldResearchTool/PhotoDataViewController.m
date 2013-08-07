//
//  PhotoDataViewController.m
//  FieldResearchTool
//
//  Created by Nick Heindl on 7/25/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "PhotoDataViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>
#import "AppModel.h"
#import "SaveObservationAndJudgementDelegate.h"



@interface PhotoDataViewController ()<SaveObservationDelegate>{
    UIImageView *showPictureView;
    UIImageView *cameraImageView;
    UIView *recorderView;
    UIButton *retakeButton;
    UIButton *redXButton;
}
@end

@implementation PhotoDataViewController
@synthesize projectComponent;
@synthesize prevData;
@synthesize newObservation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad{
    
    [super viewDidLoad];
    
    //Still has to be resized here because it's parent changes when the PhotoVC is pushed on.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    showPictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * .75)];
    showPictureView.backgroundColor = [UIColor blackColor];
    
    if(prevData){
        //this will change once the media manager is implemented
        Media *media = prevData.media;
        NSString *path = media.mediaURL;
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        showPictureView.image = image;
        showPictureView.alpha = 1;
    }
    else{
        UIImage *image = [UIImage imageNamed:@"tutorialPhoto.jpg"];
        showPictureView.image = image;
        showPictureView.alpha = .3f;
    }

    [self.view addSubview:showPictureView];
    
    //NSLog(@"X: %f, Y: %f, Width: %f, Height: %f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    UIImage *redX = [UIImage imageNamed:@"60-xRED.png"];
    redXButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - redX.size.width, 310.0f - redX.size.height, redX.size.width, redX.size.height)];
    [redXButton setImage:redX forState:UIControlStateNormal];
    [redXButton addTarget:self
                   action:@selector(redXPressed)
         forControlEvents:UIControlEventTouchUpInside];
    
    retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    retakeButton.frame = showPictureView.bounds;
    if (newObservation) {
        [retakeButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIImage *cameraImage = [UIImage imageNamed:@"86-camera.png"];
    cameraImageView = [[UIImageView alloc] initWithImage:cameraImage];
    cameraImageView.frame = CGRectMake(160 - (cameraImage.size.width / 2.0f), 148, cameraImage.size.width, cameraImage.size.height);
    
    if(!prevData){
        cameraImageView.hidden = NO;
        redXButton.hidden = YES;
        retakeButton.enabled = YES;
    }
    else{
        cameraImageView.hidden = YES;
        redXButton.hidden = NO;
        retakeButton.enabled = NO;
    }

    [self.view addSubview:cameraImageView];
    [self.view addSubview:redXButton];
    [self.view addSubview:retakeButton];
}


-(void)startRecord{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark - Image Picker Controller Functions
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    showPictureView.image = chosenImage;
    showPictureView.alpha = 1;
    cameraImageView.hidden = YES;
    
    redXButton.hidden = NO;
    retakeButton.enabled = NO;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark red x pressed
-(void)redXPressed{
    redXButton.hidden = YES;
    retakeButton.enabled = YES;
    cameraImageView.hidden = NO;
    UIImage *image = [UIImage imageNamed:@"tutorialPhoto.jpg"];
    showPictureView.image = image;
    showPictureView.alpha = .3f;
}


#pragma mark - Save Observation Data
-(UserObservationComponentData *)saveObservationData{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //get uuid here to uniquely identify the pictures
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"picTaken.png"];
    [UIImagePNGRepresentation(showPictureView.image) writeToFile:filePath atomically:YES];
    
    NSMutableDictionary *mediaAttributes = [[NSMutableDictionary alloc]init];
    [mediaAttributes setObject:[NSDate date] forKey:@"created"];
    [mediaAttributes setObject:[NSDate date] forKey:@"updated"];
    [mediaAttributes setObject:[NSNumber numberWithInt:MEDIA_PHOTO] forKey:@"type"];
    [mediaAttributes setObject:filePath forKey:@"mediaURL"];
    
    Media *picTaken = [[AppModel sharedAppModel]createNewMediaWithAttributes:mediaAttributes];
    
    NSMutableDictionary *dataAttributes = [[NSMutableDictionary alloc]init];
    [dataAttributes setObject:[NSDate date] forKey:@"created"];
    [dataAttributes setObject:[NSDate date] forKey:@"updated"];
    [dataAttributes setObject:picTaken forKey:@"media"];
    [dataAttributes setObject:projectComponent forKey:@"projectComponent"];
    
    UserObservationComponentData *data = [[AppModel sharedAppModel] createNewObservationDataWithAttributes:dataAttributes];
    return data;
}

#pragma mark - Cleanup
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
