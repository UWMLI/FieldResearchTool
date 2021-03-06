//
//  InterpretationDiscussionPostViewController.m
//  FieldResearchTool
//
//  Created by Justin Moeller on 8/6/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "InterpretationDiscussionPostViewController.h"

@interface InterpretationDiscussionPostViewController () <UITextFieldDelegate>

@end

@implementation InterpretationDiscussionPostViewController
@synthesize textBox;
@synthesize delegate;
@synthesize prevPost;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(backButtonTouchAction)];
    self.navigationItem.leftBarButtonItem = backButton;
    if(prevPost){
        self.textBox.text = prevPost.text;
        self.textBox.editable = NO;
    }
    else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTouchAction)];
        [self.textBox becomeFirstResponder];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if([self.textBox.text isEqualToString:@"Write some text here..."])
        [self.textBox setText:@""];
    self.textBox.frame = CGRectMake(0, 0, 320, 230);
}

- (void) backButtonTouchAction
{
    [self.delegate cancelled];
}

- (void) saveButtonTouchAction
{
    [self.delegate textChosen:textBox.text];
}

@end
