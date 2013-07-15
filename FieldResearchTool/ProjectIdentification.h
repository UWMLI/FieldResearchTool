//
//  ProjectIdentification.h
//  FieldResearchTool
//
//  Created by Justin Moeller on 7/15/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project, ProjectIdentificationComponentPossibility, UserObservationIdentification;

@interface ProjectIdentification : NSManagedObject

@property (nonatomic, retain) NSNumber * authorCreated;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * identificationDescription;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) NSSet *projectIdentificationComponentPossibilities;
@property (nonatomic, retain) NSSet *userObservationIdentifications;
@end

@interface ProjectIdentification (CoreDataGeneratedAccessors)

- (void)addProjectIdentificationComponentPossibilitiesObject:(ProjectIdentificationComponentPossibility *)value;
- (void)removeProjectIdentificationComponentPossibilitiesObject:(ProjectIdentificationComponentPossibility *)value;
- (void)addProjectIdentificationComponentPossibilities:(NSSet *)values;
- (void)removeProjectIdentificationComponentPossibilities:(NSSet *)values;

- (void)addUserObservationIdentificationsObject:(UserObservationIdentification *)value;
- (void)removeUserObservationIdentificationsObject:(UserObservationIdentification *)value;
- (void)addUserObservationIdentifications:(NSSet *)values;
- (void)removeUserObservationIdentifications:(NSSet *)values;

@end