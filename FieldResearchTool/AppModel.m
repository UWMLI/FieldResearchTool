//
//  AppModel.m
//  FieldResearchTool
//
//  Created by Justin Moeller on 7/16/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "AppModel.h"
#import "UserObservationComponentDataJudgement.h"
#import "ObservationJudgementType.h"
#import "ProjectComponent.h"
#import "UserObservationIdentification.h"
#import "ProjectIdentification.h"
#import "MediaManager.h"

@implementation AppModel

@synthesize coreData;
@synthesize currentProject;
@synthesize currentProjectComponents;
@synthesize allProjectIdentifications;
@synthesize currentUserObservation;
@synthesize currentUser;
@synthesize identificationImages;
@synthesize imagesLoaded;

+ (id)sharedAppModel
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark Init/dealloc
- (id) init
{
    self = [super init];
    if(self)
    {
        coreData = [[CoreDataWrapper alloc]init];
	}
    return self;
}

#pragma mark fetches

-(void)getAllProjectsWithHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchAllEntities:@"Project" withHandler:handler target:target];
        });
    });
}

-(void)getAllProjectComponentsWithHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchAllEntities:@"ProjectComponent" withAttribute:@"project.name" equalTo:currentProject.name withHandler:handler target:target];
        });
    });
}

-(void)handleFetchAllProjectComponentsForProjectName:(NSArray *)components{
    self.currentProjectComponents = components;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ProjectComponentsResponseReady" object:nil]];
}

-(void)getAllProjectIdentificationsWithHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchAllEntities:@"ProjectIdentification" withAttribute:@"project.name" equalTo:currentProject.name withHandler:handler target:target];
        });
    });

}

-(void)handleFetchProjectIdentifications:(NSArray *)identifications{
    self.allProjectIdentifications = identifications;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ProjectIdentificationsResponseReady" object:nil]];
}

-(void)getProjectIdentificationsWithAttributes:(NSDictionary *)attributeNamesAndValues withHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchEntities:@"ProjectIdentification" withAttributes:attributeNamesAndValues withHandler:handler target:target];
        });
    });
}

-(void)getUserObservationsWithHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchAllEntities:@"UserObservation" withHandler:handler target:target];
        });
    });
}

-(void)getUserObservationsForCurrentUserWithHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchAllEntities:@"UserObservation" withAttribute:@"user.name" equalTo:currentUser.name withHandler:handler target:target];
        });
    });
}

-(void)getUserObservationComponentsDataWithHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchAllEntities:@"UserObservationComponentData" withHandler:handler target:target];
        });
    });
}

-(void)getUserForName:(NSString *)username password:(NSString *)password withHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
            [attributes setValue:username forKey:@"name"];
            [attributes setValue:password forKey:@"password"];
            [coreData fetchEntities:@"User" withAttributes:attributes withHandler:handler target:target];
        });
    });
}

-(void)getUserForName:(NSString *)username withHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
            [attributes setValue:username forKey:@"name"];
            [coreData fetchEntities:@"User" withAttributes:attributes withHandler:handler target:target];
        });
    });
}

-(void)getProjectComponentPossibilitiesWithAttributes:(NSDictionary *)attributeNamesAndValies withHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchEntities:@"ProjectComponentPossibility" withAttributes:attributeNamesAndValies withHandler:handler target:target];
        });
    });
}

-(void)getProjectIdentificationComponentPossibilitiesForPossibility:(ProjectComponentPossibility *)possibility withHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            ProjectComponent *component = possibility.projectComponent;
            NSNumber *type = component.observationJudgementType;
            switch ([type intValue]) {
                case JUDGEMENT_ENUMERATOR:
                    [coreData fetchAllEntities:@"ProjectIdentificationComponentPossibility" withAttribute:@"projectComponentPossibility.enumValue" equalTo:possibility.enumValue withHandler:handler target:target];
                    break;
                default:
                    NSLog(@"Not fetching any possibilities because App Model isn't implemented");
                    break;
            }
        });
    });
}

-(void)getProjectIdentificationDiscussionsWithHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchAllEntities:@"ProjectIdentificationDiscussion" withHandler:handler target:target];
        });
    });
}

-(void)getProjectIdentificationDiscussionPostsWithAttributes:(NSDictionary *)attributes withHandler:(SEL)handler target:(id)target{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [coreData fetchEntities:@"ProjectIdentificationDiscussionPost" withAttributes:attributes withHandler:handler target:target];
        });
    });
}


#pragma mark saving

-(BOOL)save{
    return [coreData save];
}

#pragma mark creations

-(User *)createNewUserWithAttributes:(NSDictionary*)attributes{
    User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:coreData.managedObjectContext];
    for (NSString *key in attributes) {
        id value = [attributes objectForKey:key];
        [user setValue:value forKey:key];
    }
    [self save];
    return user;
}

-(UserObservation *)createNewUserObservationWithAttributes:(NSDictionary *)attributes{
    UserObservation *observation = (UserObservation *)[NSEntityDescription insertNewObjectForEntityForName:@"UserObservation" inManagedObjectContext:coreData.managedObjectContext];
    observation.user = currentUser;
    for (NSString *key in attributes) {
        id value = [attributes objectForKey:key];
        [observation setValue:value forKey:key];
    }
    self.currentUserObservation = observation;
    [self save];
    return observation;
}

-(UserObservationComponentData *)createNewObservationDataWithAttributes:(NSDictionary *)attributes{
    UserObservationComponentData *data = (UserObservationComponentData *)[NSEntityDescription insertNewObjectForEntityForName:@"UserObservationComponentData" inManagedObjectContext:coreData.managedObjectContext];
    data.userObservation = currentUserObservation;
    data.wasJudged = [NSNumber numberWithBool:NO];
    for (NSString *key in attributes) {
        id value = [attributes objectForKey:key];
        [data setValue:value forKey:key];
    }
    ProjectComponent *associateProjectComponent = data.projectComponent;
    NSLog(@"IS COMPONENT FILTERABLE: %@", associateProjectComponent.filter);
    if ([associateProjectComponent.filter boolValue]) {
        data.isFiltered = [NSNumber numberWithBool:YES];
    }
    else{
        data.isFiltered = [NSNumber numberWithBool:NO];
    }
    [self save];
    return data;
}

-(UserObservationComponentDataJudgement *)createNewJudgementWithData:(UserObservationComponentData *)data withProjectComponentPossibility:(ProjectComponentPossibility *)possibility withAttributes:(NSDictionary *)attributes{
    UserObservationComponentDataJudgement *judgement = (UserObservationComponentDataJudgement *)[NSEntityDescription insertNewObjectForEntityForName:@"UserObservationComponentDataJudgement" inManagedObjectContext:coreData.managedObjectContext];
    data.wasJudged = [NSNumber numberWithBool:YES];
    judgement.userObservationComponentData = data;
    judgement.projectComponentPossibility = possibility;
    for (NSString *key in attributes) {
        id value = [attributes objectForKey:key];
        [judgement setValue:value forKey:key];
    }
    [self save];
    return judgement;
}

-(Media *)createNewMediaWithAttributes:(NSDictionary *)attributes{
    Media *media = (Media *)[NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:coreData.managedObjectContext];
    for (NSString *key in attributes) {
        id value = [attributes objectForKey:key];
        [media setValue:value forKey:key];
    }
    [self save];
    return media;
}

-(ProjectIdentificationDiscussionPost *)createNewProjectIdentificationDiscussionPostWithAttributes:(NSDictionary *)attributes{
    ProjectIdentificationDiscussionPost *post = (ProjectIdentificationDiscussionPost *)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectIdentificationDiscussionPost" inManagedObjectContext:coreData.managedObjectContext];
    post.user = currentUser;
    for (NSString *key in attributes) {
        id value = [attributes objectForKey:key];
        [post setValue:value forKey:key];
    }
    [self save];
    return post;
}

-(UserObservationIdentification *)createNewUserObservationIdentificationWithProjectIdentification:(ProjectIdentification *) projectIdentification withAttributes:(NSDictionary *)attributes{
    UserObservationIdentification *userIdentification = (UserObservationIdentification *)[NSEntityDescription insertNewObjectForEntityForName:@"UserObservationIdentification" inManagedObjectContext:coreData.managedObjectContext];
    userIdentification.userObservation = currentUserObservation;
    userIdentification.projectIdentification = projectIdentification;
    for (NSString *key in attributes) {
        id value = [attributes objectForKey:key];
        [userIdentification setValue:value forKey:key];
    }
    [self save];
    return userIdentification;
}

-(void)deleteObject:(NSManagedObject *)objectToDelete{
    [coreData deleteObject:objectToDelete];
}

-(void)deleteObjects:(NSArray *)objectsToDelete{
    [coreData deleteObjects:objectsToDelete];
}

-(void)loadIdentificationImages{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImages) object:nil];
    [thread start];
}

-(void)loadImages{
    NSLog(@"LOADING IMAGES...");
    imagesLoaded = NO;
    [AppModel sharedAppModel].identificationImages = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < allProjectIdentifications.count; i++) {
        ProjectIdentification *identification = [allProjectIdentifications objectAtIndex:i];
        UIImage *identificationImage = [self loadDefaultImageForIdentification:identification];
        [self->identificationImages setObject:identificationImage forKey:identification.title];
    }
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LoadDefaultImages" object:nil]];
    NSLog(@"IMAGES LOADED!");
    imagesLoaded = YES;
}

-(UIImage *)loadDefaultImageForIdentification:(ProjectIdentification *)identification{
    NSString *identificationTitleString = identification.title;
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@" "];
    identificationTitleString = [[identificationTitleString componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"_"];
    UIImage *defaultImage = [[MediaManager sharedMediaManager] imageWithImage:[[MediaManager sharedMediaManager] getImageNamed:[NSString stringWithFormat:@"%@-default.jpg",identificationTitleString]] scaledToSize:CGRectMake(0, 0, 80, 80).size];
    if ([[MediaManager sharedMediaManager] getImageNamed:[NSString stringWithFormat:@"%@-default.jpg",identificationTitleString]] == nil) {
        defaultImage = [[MediaManager sharedMediaManager] imageWithImage:[[MediaManager sharedMediaManager] getImageNamed:@"defaultIdentificationNoPhoto"] scaledToSize:CGRectMake(0, 0, 80, 80).size];
    }
    return defaultImage;
}

@end
