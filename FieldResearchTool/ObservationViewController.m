//
//  ObservationViewController.m
//  FieldResearchTool
//
//  Created by Justin Moeller on 7/15/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "ObservationViewController.h"
#import "ObservationBooleanViewController.h"
#import "ObservationAudioVideoViewController.h"
#import "ObservationNumberViewController.h"
#import "ObservationPhotoViewController.h"
#import "ObservationTextViewController.h"
#import "InterpretationChoiceViewController.h"

@interface ObservationViewController ()

@end

@implementation ObservationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"New Observation";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"Backzz" style:UIBarButtonItemStyleBordered target:nil action:nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Table View Controller Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            //number of project components
            return 2;
        case 2:
            return 2;
        case 3:
            return 5;
        case 4:
            return 1;
        default:
            return 0;
    };
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"18 Interpretations";
            break;
        case 1:
            cell.textLabel.text = @"Project Components";
            break;
        case 2:
            if(indexPath.row == 0){
                cell.textLabel.text = @"Location";
            }
            else{
                cell.textLabel.text = @"Date Time";
            }
            break;
        case 3:
            if(indexPath.row == 0){
                cell.textLabel.text = @"BOOL";
            }
            else if (indexPath.row == 1){
                cell.textLabel.text = @"AV";
            }
            else if (indexPath.row == 2){
                cell.textLabel.text = @"TEXT";
            }
            else if (indexPath.row == 3){
                cell.textLabel.text = @"NUMBER";
            }
            else{
                cell.textLabel.text = @"PHOTO";
            }
            break;
        case 4:
            cell.textLabel.text = @"INTERPRETATION CHOICE";
            break;
        default:
            cell.textLabel.text = @"Dummy Data";
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 3 && indexPath.row == 0){
        NSLog(@"TESTING OTHER OBSERVATION VCZZZZZZ");
        ObservationBooleanViewController *vc = [[ObservationBooleanViewController alloc]initWithNibName:@"ObservationBooleanViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if(indexPath.section == 3 && indexPath.row == 1){
        NSLog(@"TESTING OTHER OBSERVATION VCZZZZZZ");
        ObservationAudioVideoViewController *vc = [[ObservationAudioVideoViewController alloc]initWithNibName:@"ObservationAudioVideoViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if(indexPath.section == 3 && indexPath.row == 2){
        NSLog(@"TESTING OTHER OBSERVATION VCZZZZZZ");
        ObservationTextViewController *vc = [[ObservationTextViewController alloc]initWithNibName:@"ObservationTextViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if(indexPath.section == 3 && indexPath.row == 3){
        NSLog(@"TESTING OTHER OBSERVATION VCZZZZZZ");
        ObservationNumberViewController *vc = [[ObservationNumberViewController alloc]initWithNibName:@"ObservationNumberViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if(indexPath.section == 3 && indexPath.row == 4){
        NSLog(@"TESTING OTHER OBSERVATION VCZZZZZZ");
        ObservationPhotoViewController *vc = [[ObservationPhotoViewController alloc]initWithNibName:@"ObservationPhotoViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if(indexPath.section == 4 && indexPath.row == 0){
        NSLog(@"TESTING OTHER OBSERVATION VCZZZZZZ");
        InterpretationChoiceViewController *vc = [[InterpretationChoiceViewController alloc]initWithNibName:@"InterpretationChoiceViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
