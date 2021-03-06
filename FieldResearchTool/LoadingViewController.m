//
//  LoadingViewController.m
//  FieldResearchTool
//
//  Created by Justin Moeller on 8/28/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "LoadingViewController.h"
#import "AppModel.h"
#import "IncrementalStore.h"
#import "Project.h"
#import "ProjectComponent.h"
#import "ProjectIdentification.h"
#import "ProjectComponentPossibility.h"
#import "ProjectIdentificationComponentPossibility.h"
#import "RangeOperators.h"
#import "Media.h"
#import "MediaType.h"
#import "ObservationDataType.h"
#import "ObservationJudgementType.h"
#import "ProjectIdentificationDiscussion.h"
#import "ObservationProfileViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

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
    
    
    [self.navigationController.navigationBar setHidden:YES];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"fetchData"]) {
        //[self readInSampleData];
        [self performSelector:@selector(readInSampleData) withObject:nil afterDelay:.1];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [[AppModel sharedAppModel] getAllProjectsWithHandler:@selector(handleFetchOfAllProjects:) target:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleFetchOfAllProjects:(NSArray *)projects{
    ObservationProfileViewController *newObservation = [[ObservationProfileViewController alloc]initWithNibName:@"ObservationProfileViewController" bundle:nil];
    
    Project *project = projects[0];
    [AppModel sharedAppModel].currentProject = project;
    [self.navigationController pushViewController:newObservation animated:YES];
    [[AppModel sharedAppModel]getAllProjectIdentificationsWithHandler:@selector(handleIdentificationImageCall:) target:self];
}

-(void)handleIdentificationImageCall:(NSArray *)identifications{
    [AppModel sharedAppModel].allProjectIdentifications = identifications;
    [[AppModel sharedAppModel] loadIdentificationImages];
}

#pragma mark Sample Data
-(void)readInSampleData{
    
    Project *project = (Project *)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
    project.allowedInterpretations = [NSNumber numberWithInt:1];
    project.created = [NSDate date];
    project.updated = [NSDate date];
    project.name = @"Biocore";
    //add media reference here
    
    [AppModel sharedAppModel].currentProject = project;
    
    //create an 'editor' user. this user will be used for creating discussion topics
    User *editor = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
    editor.name = @"Editor";
    editor.password = @"editor";
    editor.created = [NSDate date];
    editor.updated = [NSDate date];
    editor.project = project;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"examplePlantData" ofType:@"tsv"];
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *firstLine = lines[0];
    NSArray *wordsSeperatedByTabs = [firstLine componentsSeparatedByString:@"\t"];
    NSMutableArray *projectComponents = [[NSMutableArray alloc]init];
    NSMutableArray *discussionTopics = [[NSMutableArray alloc]init];
    int nonComponents = 0;
    for(int i = 0; i < [wordsSeperatedByTabs count]; i++){
        NSString *componentRegex = @".*(\\{YES\\}|\\{NO\\})?(\\{DATA_VIDEO\\}|\\{DATA_PHOTO\\}|\\{DATA_AUDIO\\}|\\{DATA_TEXT\\}|\\{DATA_LONG_TEXT\\}|\\{DATA_NUMBER\\}|\\{DATA_BOOL\\}|\\{DATA_ENUM\\})(\\{JUDGEMENT_TEXT\\}|\\{JUDGEMENT_LONG_TEXT\\}|\\{JUDGEMENT_NUMBER\\}|\\{JUDGEMENT_BOOL\\}|\\{JUDGEMENT_ENUM\\})(\\{FILTER\\}|\\{DONT_FILTER\\})(\\{.*\\})";
        BOOL isComponent = [self stringMatchesRegex:wordsSeperatedByTabs[i] regex:componentRegex];
        if(isComponent){
            NSString *leftBrace = @"{";
            NSInteger leftBraceIndex = [wordsSeperatedByTabs[i] rangeOfString:leftBrace].location;
            NSString *withoutParams = [wordsSeperatedByTabs[i] substringToIndex:leftBraceIndex];
            NSString *params = [wordsSeperatedByTabs[i] substringFromIndex:leftBraceIndex];
            
            NSString *dash = @"-";
            NSInteger dashIndex = [withoutParams rangeOfString:dash].location;
            
            NSString *projectComponentName = withoutParams;
            if(dashIndex != NSNotFound){
                projectComponentName = [withoutParams substringToIndex:dashIndex];
            }
            
            NSString *requiredRegex = @"(\\{YES\\}.*)";
            BOOL isRequired = [self stringMatchesRegex:params regex:requiredRegex];
            
            //figure out the observation type
            ObservationDataType dataType;
            NSString *videoRegex = @"(.*\\{DATA_VIDEO\\}.*)";
            NSString *audioRegex = @"(.*\\{DATA_AUDIO\\}.*)";
            NSString *photoRegex = @"(.*\\{DATA_PHOTO\\}.*)";
            NSString *textRegex = @"(.*\\{DATA_TEXT\\}.*)";
            NSString *longTextRegex = @"(.*\\{DATA_LONG_TEXT\\}.*)";
            NSString *numberRegex = @"(.*\\{DATA_NUMBER\\}.*)";
            NSString *boolRegex = @"(.*\\{DATA_BOOL\\}.*)";
            NSString *enumRegex = @"(.*\\{DATA_ENUM\\}.*)";
            if([self stringMatchesRegex:params regex:videoRegex]){
                dataType = DATA_VIDEO;
            }
            else if([self stringMatchesRegex:params regex:audioRegex]){
                dataType = DATA_AUDIO;
            }
            else if([self stringMatchesRegex:params regex:photoRegex]){
                dataType = DATA_PHOTO;
            }
            else if([self stringMatchesRegex:params regex:textRegex]){
                dataType = DATA_TEXT;
            }
            else if([self stringMatchesRegex:params regex:longTextRegex]){
                dataType = DATA_LONG_TEXT;
            }
            else if([self stringMatchesRegex:params regex:numberRegex]){
                dataType = DATA_NUMBER;
            }
            else if([self stringMatchesRegex:params regex:boolRegex]){
                dataType = DATA_BOOLEAN;
            }
            else if([self stringMatchesRegex:params regex:enumRegex]){
                dataType = DATA_ENUMERATOR;
            }
            else{
                NSLog(@"Error in setting type for Project Component");
                dataType = DATA_NUMBER;
            }
            
            //figure out the judgement type
            ObservationJudgementType judgementType;
            videoRegex = @"(.*\\{JUDGEMENT_VIDEO\\}.*)";
            audioRegex = @"(.*\\{JUDGEMENT_AUDIO\\}.*)";
            photoRegex = @"(.*\\{JUDGEMENT_PHOTO\\}.*)";
            textRegex = @"(.*\\{JUDGEMENT_TEXT\\}.*)";
            longTextRegex = @"(.*\\{JUDGEMENT_LONG_TEXT\\}.*)";
            numberRegex = @"(.*\\{JUDGEMENT_NUMBER\\}.*)";
            boolRegex = @"(.*\\{JUDGEMENT_BOOL\\}.*)";
            enumRegex = @"(.*\\{JUDGEMENT_ENUM\\}.*)";
            if([self stringMatchesRegex:params regex:textRegex]){
                judgementType = JUDGEMENT_TEXT;
            }
            else if([self stringMatchesRegex:params regex:longTextRegex]){
                judgementType = JUDGEMENT_LONG_TEXT;
            }
            else if([self stringMatchesRegex:params regex:numberRegex]){
                judgementType = JUDGEMENT_NUMBER;
            }
            else if([self stringMatchesRegex:params regex:boolRegex]){
                judgementType = JUDGEMENT_BOOLEAN;
            }
            else if([self stringMatchesRegex:params regex:enumRegex]){
                judgementType = JUDGEMENT_ENUMERATOR;
            }
            else{
                NSLog(@"Error in setting type for Project Component");
                judgementType = JUDGEMENT_NUMBER;
            }
            
            BOOL filter;
            if(judgementType == JUDGEMENT_BOOLEAN || judgementType == JUDGEMENT_ENUMERATOR || judgementType == JUDGEMENT_NUMBER){
                NSString *filterRegex = @".*\\{FILTER\\}.*";
                NSString *dontFilterRegex = @".*\\DONT_FILTER\\}.*";
                if([self stringMatchesRegex:params regex:filterRegex]){
                    filter = YES;
                }
                else if ([self stringMatchesRegex:params regex:dontFilterRegex]){
                    filter = NO;
                }
                else{
                    NSLog(@"Something went wrong when trying to set filter for component");
                    filter = NO;
                }
            }
            else{
                filter = NO;
            }
            
            int startingLocation = [params rangeOfString:@"{" options:NSBackwardsSearch].location;
            NSString *description = [params substringFromIndex:startingLocation+1];
            NSString *componentDescription = [description substringToIndex:description.length - 1];
            
            ProjectComponent *projectComponent = (ProjectComponent *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectComponent" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
            projectComponent.created = [NSDate date];
            projectComponent.updated = [NSDate date];
            projectComponent.observationDataType = [NSNumber numberWithInt:dataType];
            projectComponent.observationJudgementType = [NSNumber numberWithInt:judgementType];
            projectComponent.required = [NSNumber numberWithBool:isRequired];
            projectComponent.title = projectComponentName;
            projectComponent.project = project;
            projectComponent.filter = [NSNumber numberWithBool:filter];
            projectComponent.prompt = componentDescription;
            
            ///////////////NICK MADE
            //Make the filename for the media
            NSString *projectComponentTitleString = projectComponentName;
            NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@" "];
            projectComponentTitleString = [[projectComponentTitleString componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"_"];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:projectComponentTitleString];
            
            NSMutableDictionary *mediaAttributes = [[NSMutableDictionary alloc]init];
            [mediaAttributes setObject:[NSDate date] forKey:@"created"];
            [mediaAttributes setObject:[NSDate date] forKey:@"updated"];
            [mediaAttributes setObject:[NSNumber numberWithInt:MEDIA_PHOTO] forKey:@"type"];
            [mediaAttributes setObject:filePath forKey:@"mediaURL"];
            
            Media *projectComponentMedia = [[AppModel sharedAppModel]createNewMediaWithAttributes:mediaAttributes];
            projectComponent.media = projectComponentMedia;
            ///////////////NICK MADE
            
            [projectComponents addObject:projectComponent];
            
            
            
            if (dashIndex != NSNotFound) {
                NSString *stringProjectComponentPossibilities = [withoutParams substringFromIndex:dashIndex+2];
                NSArray *projectComponentPossibilities = [stringProjectComponentPossibilities componentsSeparatedByString:@", "];
                for (int j = 0; j < [projectComponentPossibilities count]; j++) {
                    NSString *stringProjectComponentPossibility = projectComponentPossibilities[j];
                    ProjectComponentPossibility *projectComponentPossibility = (ProjectComponentPossibility *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectComponentPossibility" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                    projectComponentPossibility.created = [NSDate date];
                    projectComponentPossibility.updated = [NSDate date];
                    projectComponentPossibility.projectComponent = projectComponent;
                    
                    if(judgementType == JUDGEMENT_ENUMERATOR){
                        projectComponentPossibility.enumValue = stringProjectComponentPossibility;
                    }
                    else{
                        NSLog(@"Error parsing project possibilities. Something other than enum is specified after the dash. Component: %@", projectComponent.title);
                    }
                }
            }
            else{
                if(judgementType == JUDGEMENT_BOOLEAN){
                    ProjectComponentPossibility *projectComponentPossibilityYES = (ProjectComponentPossibility *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectComponentPossibility" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                    projectComponentPossibilityYES.created = [NSDate date];
                    projectComponentPossibilityYES.updated = [NSDate date];
                    projectComponentPossibilityYES.projectComponent = projectComponent;
                    projectComponentPossibilityYES.boolValue = [NSNumber numberWithBool:YES];
                    
                    ProjectComponentPossibility *projectComponentPossibilityNO = (ProjectComponentPossibility *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectComponentPossibility" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                    projectComponentPossibilityNO.created = [NSDate date];
                    projectComponentPossibilityNO.updated = [NSDate date];
                    projectComponentPossibilityNO.projectComponent = projectComponent;
                    projectComponentPossibilityNO.boolValue = [NSNumber numberWithBool:NO];
                }
            }
        }
        else{
            nonComponents++;
            NSString *helpString = @"Components go to the right of this column FORMAT: <Component Name> DASH <Component Possibility>, <Component Possibility>, .... LEFT CURLY BRACE isRequired RIGHT CURLY BRACE LEFT CURLY BRACE <Observation Type> RIGHT CURLY BRACE LEFT CURLY BRACE <Data Type> RIGHT CURLY BRACE LEFT CURLY BRACE isFilterable RIGHT CURLY BRACE LEFT CURLY BRACE <Judgement description> RIGHT CURLY BRACE";
            if(i > 3 && ![self stringMatchesRegex:wordsSeperatedByTabs[i] regex:helpString]){
                ProjectIdentificationDiscussion *discussion = (ProjectIdentificationDiscussion *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectIdentificationDiscussion" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                discussion.created = [NSDate date];
                discussion.updated = [NSDate date];
                discussion.title = wordsSeperatedByTabs[i];
                //create media object here and attach it
                discussion.project = project;
                [discussionTopics addObject:discussion];
                //NSLog(@"Adding discussion topic: %@", discussion.title);
            }
        }
    }
    
    //read in the actual data
    for(int i = 1; i < [lines count]; i++){
        
        NSArray *components = [lines[i] componentsSeparatedByString:@"\t"];
        ProjectIdentification *identification = (ProjectIdentification *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectIdentification" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
        identification.authorCreated = [NSNumber numberWithBool:YES];
        identification.created = [NSDate date];
        identification.updated = [NSDate date];
        identification.identificationDescription = components[2];
        identification.alternateName = components[0];
        identification.title = components[1];
        identification.score = [NSNumber numberWithFloat:0.0f];
        identification.numOfNils = [NSNumber numberWithInt:0];
        //add media array here
        //make a media object for everything in there, and then make a set of those media objects, and assign it to identification.media
        //Parse string separated by commas. make a media object with that string.
        NSString *mediaToParse = components[3];
        NSArray *mediaSubstrings = [mediaToParse componentsSeparatedByString:@", "];
        
        //////////////////////////////MADE BY NICK////////////////////
        
        NSMutableArray *mediaObjects = [[NSMutableArray alloc]init];
        for (int j = 0; j < [mediaSubstrings count]; j++) {
            //make a media object for every iteration through here
            NSMutableDictionary *mediaAttributes = [[NSMutableDictionary alloc]init];
            [mediaAttributes setObject:[NSDate date] forKey:@"created"];
            [mediaAttributes setObject:[NSDate date] forKey:@"updated"];
            [mediaAttributes setObject:[NSNumber numberWithInt:MEDIA_PHOTO] forKey:@"type"];
            
            //Get rid of spaces if editors puts them in >.>
            NSString *mediaTitleString = mediaSubstrings[j];
            NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@" "];
            mediaTitleString = [[mediaTitleString componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"_"];
            
            [mediaAttributes setObject:mediaTitleString forKey:@"mediaURL"];//this isn't path for now, just name
            
            Media *mediaObject = [[AppModel sharedAppModel]createNewMediaWithAttributes:mediaAttributes];
            [mediaObjects insertObject:mediaObject atIndex:j];
        }
        NSSet *mediaSet = [NSSet setWithArray:mediaObjects];
        identification.media = mediaSet;
        //////////////////////////////MADE BY NICK////////////////////
        
        identification.project = project;
        
        int numOfNonComponents = nonComponents;
        for (int j = 0; j < [components count]; j++) {
            
            NSString *commaListOfComponentPossibilities = components[j];
            if(j >= numOfNonComponents){
                ProjectComponent *associatedProjectComponent = [projectComponents objectAtIndex:j-numOfNonComponents];
                
                if([commaListOfComponentPossibilities isEqualToString:@""]){
                    //create special 'nil' possibility for data that isn't filled out
                    ProjectComponentPossibility *nilPossibility = (ProjectComponentPossibility *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectComponentPossibility" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                    nilPossibility.created = [NSDate date];
                    nilPossibility.updated = [NSDate date];
                    nilPossibility.enumValue = @""; //special value for nil possibility
                    nilPossibility.projectComponent = associatedProjectComponent;
                    //create a 'pairing' of the identification and nil so we can find where data isn't filled out in the table
                    ProjectIdentificationComponentPossibility *projectIdentificationComponentPossibility = (ProjectIdentificationComponentPossibility *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectIdentificationComponentPossibility" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                    projectIdentificationComponentPossibility.created = [NSDate date];
                    projectIdentificationComponentPossibility.updated = [NSDate date];
                    projectIdentificationComponentPossibility.projectComponentPossibility = nilPossibility;
                    projectIdentificationComponentPossibility.projectIdentification = identification;
                    //NSLog(@"Creating identification component possibility for identification: %@ with nil possibility", identification.title);
                    continue;
                }
                
                NSArray *componentPossibilities = [commaListOfComponentPossibilities componentsSeparatedByString:@", "];
                
                
                for(int k = 0; k < [componentPossibilities count]; k++){
                    //create the possibilities for numbers and text
                    //                    NSString *debugPossibility = componentPossibilities[k];
                    //                    NSLog(@"Debug Possibility: %@", debugPossibility);
                    ProjectComponentPossibility *componentPossibility;
                    if(associatedProjectComponent.observationJudgementType == [NSNumber numberWithInt:JUDGEMENT_NUMBER] || associatedProjectComponent.observationJudgementType == [NSNumber numberWithInt:JUDGEMENT_TEXT] || associatedProjectComponent.observationJudgementType == [NSNumber numberWithInt:JUDGEMENT_LONG_TEXT]){
                        
                        componentPossibility = (ProjectComponentPossibility *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectComponentPossibility" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                        componentPossibility.created = [NSDate date];
                        componentPossibility.updated = [NSDate date];
                        if(associatedProjectComponent.observationJudgementType == [NSNumber numberWithInt:JUDGEMENT_NUMBER]){
                            if(k == 0){
                                if([componentPossibilities count] != 2){
                                    NSLog(@"Error parsing number, more than two numbers were provided");
                                    continue;
                                }
                                NSString *number = componentPossibilities[0];
                                NSString *stdDev = componentPossibilities[1];
                                componentPossibility.number = [NSNumber numberWithInt:[number intValue]];
                                componentPossibility.stdDev = [NSNumber numberWithInt:[stdDev intValue]];
                                componentPossibility.projectComponent = associatedProjectComponent;
                            }
                            else{
                                continue;
                            }
                        }
                        else if(associatedProjectComponent.observationJudgementType == [NSNumber numberWithInt:JUDGEMENT_TEXT]){
                            componentPossibility.text = componentPossibilities[k];
                            componentPossibility.projectComponent = associatedProjectComponent;
                        }
                        else{
                            componentPossibility.longText = componentPossibilities[k];
                            componentPossibility.projectComponent = associatedProjectComponent;
                        }
                    }
                    else if(associatedProjectComponent.observationJudgementType == [NSNumber numberWithInt:JUDGEMENT_BOOLEAN]){
                        NSString *yesRegex = @"\\s*(YES|yes)\\s*";
                        if([self stringMatchesRegex:componentPossibilities[k] regex:yesRegex]){
                            NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
                            [attributes setObject:[NSNumber numberWithBool:YES] forKey:@"boolValue"];
                            [attributes setObject:associatedProjectComponent.title forKey:@"projectComponent.title"];
                            componentPossibility = [self fetchEntities:@"ProjectComponentPossibility" withAttributes:attributes];
                        }
                        else{
                            NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
                            [attributes setObject:[NSNumber numberWithBool:NO] forKey:@"boolValue"];
                            [attributes setObject:associatedProjectComponent.title forKey:@"projectComponent.title"];
                            componentPossibility = [self fetchEntities:@"ProjectComponentPossibility" withAttributes:attributes];
                        }
                    }
                    else{
                        NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
                        [attributes setObject:componentPossibilities[k] forKey:@"enumValue"];
                        [attributes setObject:associatedProjectComponent.title forKey:@"projectComponent.title"];
                        componentPossibility = [self fetchEntities:@"ProjectComponentPossibility" withAttributes:attributes];
                    }
                    
                    ProjectIdentificationComponentPossibility *projectIdentificationComponentPossibility = (ProjectIdentificationComponentPossibility *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectIdentificationComponentPossibility" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                    projectIdentificationComponentPossibility.created = [NSDate date];
                    projectIdentificationComponentPossibility.updated = [NSDate date];
                    projectIdentificationComponentPossibility.projectComponentPossibility = componentPossibility;
                    projectIdentificationComponentPossibility.projectIdentification = identification;
                    
                    if (!componentPossibility) {
                        NSLog(@"ERROR!!!!! Created Project Identification Component Possibility. Identification: %@ Component: %@ Possibility: %@", identification.title, associatedProjectComponent.title, componentPossibility.enumValue);
                    }
                    
                    //NSLog(@"Created Project Identification Component Possibility. Identification: %@ Component: %@ Possibility: %@", identification.title, associatedProjectComponent.title, componentPossibility.enumValue);
                    
                }
            }
            else{
                if (j > 3 && j < nonComponents-1) {
                    NSArray *discussionPosts = [commaListOfComponentPossibilities componentsSeparatedByString:@", "];
                    for (int k = 0; k < discussionPosts.count; k++) {
                        if ([discussionPosts[k] isEqualToString:@""]) {
                            continue;
                        }
                        ProjectIdentificationDiscussion *discussion = [discussionTopics objectAtIndex:j-4];
                        ProjectIdentificationDiscussionPost *post = (ProjectIdentificationDiscussionPost *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectIdentificationDiscussionPost" inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
                        post.created = [NSDate date];
                        post.updated = [NSDate date];
                        post.text = discussionPosts[k];
                        post.user = editor;
                        post.projectIdentificationDiscussion = discussion;
                        post.projectIdentification = identification;
                        //NSLog(@"Created post. User: %@ Discussion Topic: %@ Identification: %@ Text: %@", post.user.name, post.projectIdentificationDiscussion.title, post.projectIdentification.title, post.text);
                    }
                }
            }
        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fetchData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AppModel sharedAppModel] save];
}

-(BOOL)stringMatchesRegex:(NSString *)string regex:(NSString *)regex{
    NSPredicate *testRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return[testRegex evaluateWithObject: string];
}

-(ProjectComponentPossibility *)fetchEntities:(NSString *)entityName withAttributes:(NSDictionary *)attributeNamesAndValues{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[AppModel sharedAppModel].coreData.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSMutableString *predicateString = [NSMutableString stringWithString:@""];
    if(attributeNamesAndValues && [attributeNamesAndValues count] > 0){
        //create the predicate string
        for (NSString *key in attributeNamesAndValues) {
            //first check to make sure the object we're adding to the predicate string isnt nil
            if([attributeNamesAndValues objectForKey:key]){
                
                id value = [attributeNamesAndValues objectForKey:key];
                BOOL isNumeric = [value isKindOfClass:[NSNumber class]];
                if(isNumeric){
                    if([predicateString isEqualToString:@""]){
                        [predicateString appendFormat:@"%@ == %@", key, [attributeNamesAndValues objectForKey:key]];
                    }
                    else{
                        [predicateString appendFormat:@" && %@ == %@", key, [attributeNamesAndValues objectForKey:key]];
                    }
                }
                else{
                    if([predicateString isEqualToString:@""]){
                        [predicateString appendFormat:@"%@ == '%@'", key, [attributeNamesAndValues objectForKey:key]];
                    }
                    else{
                        [predicateString appendFormat:@" && %@ == '%@'", key, [attributeNamesAndValues objectForKey:key]];
                    }
                }
            }
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [fetchRequest setPredicate:predicate];
    }
    
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[AppModel sharedAppModel].coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"An error occurred when fetching entities with attributes. Handler not called. %@", error);
        return nil;
    }
    
    if([fetchedObjects count] > 1){
        NSLog(@"ERROR!!! More than one possibility was returned. %@", predicateString);
    }
    else if([fetchedObjects count] == 0){
        //NSLog(@"ERROR!!! No possibility was returned");
        return nil;
    }
    
    return fetchedObjects[0];
    
}

@end
