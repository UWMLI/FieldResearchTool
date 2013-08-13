//
//  RegisterNewAccountViewController.m
//  FieldResearchTool
//
//  Created by Nick Heindl on 8/13/13.
//  Copyright (c) 2013 UW Mobile Learning Incubator. All rights reserved.
//

#import "RegisterNewAccountViewController.h"

#import "AppModel.h"

@interface RegisterNewAccountViewController (){
    CGRect viewRect;
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UIAlertView *alert;
    NSString *username;
    NSString *password;
}

@end

@implementation RegisterNewAccountViewController

@synthesize table;

-(id)initWithFrame:(CGRect)frame{
    self = [super init];
    viewRect = frame;
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    self.view.frame = viewRect;
}

- (void) loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 100) style:UITableViewStyleGrouped];
    table.scrollEnabled = NO;
    
    table.delegate = self;
    table.dataSource = self;
    
    table.backgroundView = nil;
    table.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:table];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerButton addTarget:self action:@selector(attemptToRegister) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"Create account!" forState:UIControlStateNormal];
    registerButton.frame = CGRectMake(10.0, table.bounds.size.height, 300.0, 40.0);
    [self.view addSubview:registerButton];
    
    alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Please enter a valid username and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)attemptToRegister{
    username = usernameTextField.text;
    password = passwordTextField.text;
    NSLog(@"USER: %@ PASS: %@",username, password);
    
    if ([username length] != 0 && [password length] != 0){
        [[AppModel sharedAppModel] getUserForName:username password:password withHandler:@selector(handleFetchOfUser:) target:self];
    }
    else{
        NSLog(@"Error");
        [alert show];
    }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        default:
            return 0;
    };
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Make the identifier unique to that row so cell pictures don't get reused in funky ways.
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d", indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
            
        case 0:{
            
            if(indexPath.row == 0){
                usernameTextField = [[UITextField alloc]initWithFrame:CGRectMake(cell.bounds.origin.x + 8, cell.bounds.origin.y + 10, cell.bounds.size.width, cell.bounds.size.height)];
                usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                usernameTextField.placeholder = @"Enter your Username";
                [cell.contentView addSubview:usernameTextField];
            }
            
            else if (indexPath.row == 1){
                passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(cell.bounds.origin.x + 8, cell.bounds.origin.y + 10, cell.bounds.size.width, cell.bounds.size.height)];
                passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                passwordTextField.placeholder = @"Enter your Password";
                [cell.contentView addSubview:passwordTextField];
            }
            
        }break;
        default:
            cell.textLabel.text = @"Error :[";
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0){
//        
//    }
//    else if (indexPath.section == 1){
//        
//    }
//    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - async calls

-(void)handleFetchOfUser:(NSArray *)users{
    
    if(users == nil || [users count] != 1){
//        NSLog(@"Bad username/password combination...");
//        [alert show];
        
        //CREATE NEW USER
        User *user = users[0];
        [AppModel sharedAppModel].currentUser = user;
        [[AppModel sharedAppModel] getAllProjectsWithHandler:@selector(handleFetchOfAllProjects:) target:self];
    }
    else{
//        User *user = users[0];
//        [AppModel sharedAppModel].currentUser = user;
//        [[AppModel sharedAppModel] getAllProjectsWithHandler:@selector(handleFetchOfAllProjects:) target:self];
        NSLog(@"Bad username/password combination...");
        [alert show];
    }
    
}

@end
