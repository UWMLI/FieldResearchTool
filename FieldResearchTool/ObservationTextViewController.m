//
//  ObservationTextViewController.m
//  FieldResearchTool
//
//  Created by Nick Heindl on 7/15/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "ObservationTextViewController.h"

@interface ObservationTextViewController (){
    NSString *componentPossibilityJudgement;
}

@end

@implementation ObservationTextViewController

@synthesize componentPossibilityDescription, userInput;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
#warning TODO
    componentPossibilityDescription.text = @"WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN WHEN A FIRE STARTS TO BURN ";
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    componentPossibilityJudgement = userInput.text;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)killKeyboard:(id)sender {
    
    [self.view endEditing:YES];
}
@end
