//
//  BooleanDataViewController.m
//  FieldResearchTool
//
//  Created by Nick Heindl on 7/25/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "BooleanDataViewController.h"
#import "AppModel.h"
#import "ProjectComponentPossibility.h"
#import "SaveObservationAndJudgementDelegate.h"
#import "ProjectComponent.h"
#import "MediaManager.h"

@interface BooleanDataViewController ()<SaveObservationDelegate>{
    CGRect viewRect;
    UIImageView *imageView;
}

@end

@implementation BooleanDataViewController


@synthesize componentPossibilityDescription;
@synthesize boolSwitch;
@synthesize prevData;
@synthesize projectComponent;
@synthesize newObservation;

-(id)initWithFrame:(CGRect)frame{
    self = [super init];
    viewRect = frame;
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    self.view.frame = viewRect;
}

-(void)loadView{
    
    [super loadView];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    boolSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width *.6, 100, 100, 100)];
    
    [self.view addSubview:boolSwitch];
    
    if (prevData) {
        BOOL switchValue = [prevData.boolValue boolValue];
        [boolSwitch setOn:switchValue animated:NO];
    }
    if(!newObservation){
        boolSwitch.enabled = NO;
    }
    
    UITextView *descriptionTextField = [[UITextView alloc]initWithFrame:CGRectMake(0, viewRect.size.height * .02, viewRect.size.width, 60)];
    descriptionTextField.backgroundColor = [UIColor clearColor];
    descriptionTextField.textAlignment = NSTextAlignmentCenter;
    descriptionTextField.font = [descriptionTextField.font fontWithSize:16];
    
    descriptionTextField.editable = NO;
    
    if ([projectComponent.prompt isEqualToString:@""]) {
        descriptionTextField.text = [NSString stringWithFormat:@"Enter a number for %@.", projectComponent.title];
    }
    else{
        descriptionTextField.text = projectComponent.prompt;
    }
    
    descriptionTextField.tag = 2;
    [self.view addSubview:descriptionTextField];

    
    
    NSString *tutorialLargeString = projectComponent.title;
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@" "];
    tutorialLargeString = [[tutorialLargeString componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"_"];
    tutorialLargeString = [tutorialLargeString stringByAppendingString:@"_TutorialLarge"];
    
    //Why have this? 
    imageView = [[UIImageView alloc]initWithImage:[[MediaManager sharedMediaManager] getImageNamed:tutorialLargeString]];
    imageView.frame = CGRectMake(viewRect.size.width * .1, boolSwitch.frame.size.height + imageView.frame.size.height, 100, 100);

    imageView.image = [[MediaManager sharedMediaManager] imageWithImage:[[MediaManager sharedMediaManager] getImageNamed:tutorialLargeString] scaledToSize:CGRectMake(0, 0, self.view.bounds.size.height * .2, self.view.bounds.size.height * .2).size];
        
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark save observation data
-(UserObservationComponentData *)saveObservationData{
    
    BOOL switchValue = boolSwitch.isOn;
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
    [attributes setObject:[NSDate date] forKey:@"created"];
    [attributes setObject:[NSDate date] forKey:@"updated"];
    [attributes setObject:[NSNumber numberWithBool:switchValue] forKey:@"boolValue"];
    [attributes setObject:projectComponent forKey:@"projectComponent"];
    
    UserObservationComponentData *data = [[AppModel sharedAppModel] createNewObservationDataWithAttributes:attributes];
    return data;
}

@end

