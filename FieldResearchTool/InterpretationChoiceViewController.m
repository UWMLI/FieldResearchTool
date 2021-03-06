//
//  InterpretationChoiceViewController.m
//  FieldResearchTool
//
//  Created by Nick Heindl on 7/15/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "InterpretationChoiceViewController.h"

#import "ProjectIdentification.h"
#import "InterpretationInformationViewController.h"
#import "ObservationViewController.h"
#import "AppModel.h"
#import "MediaManager.h"

@interface InterpretationChoiceViewController (){
    
    NSMutableArray *likelyChoices;
    NSMutableArray *unlikelyChoices;
    NSMutableArray *likelyImages;
    NSMutableArray *unlikelyImages;
}

@end

@implementation InterpretationChoiceViewController
@synthesize table;
@synthesize projectIdentifications;
@synthesize dataToFilter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDefaultImagesIntoMemory) name:@"LoadDefaultImages" object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    likelyChoices = [[NSMutableArray alloc]init];
    unlikelyChoices = [[NSMutableArray alloc]init];
    for (int i = 0; i < [projectIdentifications count]; i ++) {
        
        ProjectIdentification *identification = [projectIdentifications objectAtIndex:i];
        if ([identification.score floatValue] > .8) {
            [likelyChoices addObject:identification];
        }
        else{
            [unlikelyChoices addObject:identification];
        }
    }
    
    if ([AppModel sharedAppModel].imagesLoaded) {
        [self loadDefaultImagesIntoMemory];
    }
    
    NSLog(@"CHOICE VC ViewDidLoad");
}

- (void) viewDidAppear:(BOOL)animated{
    [self.table reloadData];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [likelyChoices count];
        case 1:
            return [unlikelyChoices count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"InterpretationChoiceTableViewCell" owner:self options:nil];
        cell = [nibObjects objectAtIndex:0];
    }
    
    
    ProjectIdentification *identification;
    UIImage *defaultImage;
    
    switch (indexPath.section) {
        case 0:
            identification = [likelyChoices objectAtIndex:indexPath.row];
            if ([AppModel sharedAppModel].imagesLoaded) {
                defaultImage = [likelyImages objectAtIndex:indexPath.row];
            }
            
            break;
        case 1:
            identification = [unlikelyChoices objectAtIndex:indexPath.row];
            if ([AppModel sharedAppModel].imagesLoaded) {
                defaultImage = [unlikelyImages objectAtIndex:indexPath.row];
            }
            break;
        default:
            break;
    }
    
    if ([AppModel sharedAppModel].imagesLoaded) {
        //Image
//        UIImageView *cellImage = (UIImageView *)[cell viewWithTag:0];
//        cellImage.image = defaultImage;
        cell.imageView.image = defaultImage;
    }

    
    //Scientific Name
    UILabel *labelText = (UILabel *)[cell viewWithTag: 1];
    labelText.text = identification.title;
    //labelText.adjustsFontSizeToFitWidth = YES;
    //labelText.adjustsLetterSpacingToFitWidth = YES;
    //Common Name
    UILabel *detailLabelText = (UILabel *)[cell viewWithTag: 2];
    detailLabelText.text = identification.alternateName;
    
    //Percentage
    UILabel *labelPercentageText = (UILabel *)[cell viewWithTag: 3];    
    
    
    float decimal = [identification.score floatValue];
    float percent = decimal * 100;
    
    if(dataToFilter.count > 0){
        labelPercentageText.text = [NSString stringWithFormat:@"%.02f%% match", percent];
        
    }
    else{
        labelPercentageText.text = [NSString stringWithFormat:@"No data to filter upon!"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    InterpretationInformationViewController *interpretationInformationVC = [[InterpretationInformationViewController alloc]initWithNibName:@"InterpretationInformationViewController" bundle:nil];
    
    ProjectIdentification *identification;
    
    if(indexPath.section == 0){
        identification = [likelyChoices objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 1){
        identification = [unlikelyChoices objectAtIndex:indexPath.row];
    }
    
    interpretationInformationVC.identification = identification;
    ObservationViewController *prevVC = (ObservationViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    interpretationInformationVC.delegate = (id)prevVC;
    [self.navigationController pushViewController:interpretationInformationVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    switch (section) {
        case 0:
            if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
                return nil;
            } else {
                return [NSString stringWithFormat:@"%d Likely Options", [likelyChoices count]];
            }
            break;
        case 1:
            if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
                return nil;
            } else {
                return [NSString stringWithFormat:@"%d Unlikely Options", [unlikelyChoices count]];
            }
            
            break;
        default:
            return @"Error :'[";
            break;
    }
}

#pragma mark load default images into memory
-(void)loadDefaultImagesIntoMemory{
    likelyImages = [[NSMutableArray alloc] init];
    unlikelyImages = [[NSMutableArray alloc] init];
    for (int i = 0; i < [projectIdentifications count]; i ++) {
        ProjectIdentification *identification = [projectIdentifications objectAtIndex:i];
        UIImage *defaultImage = (UIImage *)[[AppModel sharedAppModel].identificationImages objectForKey:identification.title];
        if ([identification.score floatValue] > .8) {
            [likelyImages addObject:defaultImage];
        }
        else{
            [unlikelyImages addObject:defaultImage];
        }
    }
    [table reloadData];
}

@end
