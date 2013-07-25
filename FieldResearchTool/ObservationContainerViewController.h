//
//  ObservationContainerViewController.h
//  FieldResearchTool
//
//  Created by Nick Heindl on 7/24/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectComponent.h"

@protocol ObservationContainerViewControllerDelegate <NSObject>

- (void)observationContainerViewController:(ProjectComponent *)projectComponent;

@end




@interface ObservationContainerViewController : UIViewController

@property (strong, nonatomic) ProjectComponent *projectComponent;

@property (nonatomic, weak) id<ObservationContainerViewControllerDelegate> delegate;

@end
