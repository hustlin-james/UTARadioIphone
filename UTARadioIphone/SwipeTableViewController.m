//
//  SwipeTableViewController.m
//  UTARadioIphone
//
//  Created by James Fielder on 6/2/14.
//  Copyright (c) 2014 com.mobi. All rights reserved.
//

#import "SwipeTableViewController.h"
#import "HomeViewController.h"
#import "SongRequestViewController.h"
#import "StaffViewController.h"
#import "AudioPlayerSingleton.h"

#define menuWidth 150.0

@interface SwipeTableViewController(){
    AudioPlayerSingleton *player;
}

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *menuTable;
@property (nonatomic, strong) UIDynamicAnimator *animator;

-(void)setupMenuView;
-(void)handleGesture:(UISwipeGestureRecognizer *)gesture;
-(void)toggleMenu:(BOOL)shouldOpenMenu;

@end

@implementation SwipeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!player)
        player = [AudioPlayerSingleton singletonInstance];
    
    [self.view addSubview: [player  createBottomToolbar]];
    
	//Create the side menu
    
    [self setupMenuView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    
    UISwipeGestureRecognizer *showMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleGesture:)];
    showMenuGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:showMenuGesture];
    
    
    UISwipeGestureRecognizer *hideMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleGesture:)];
    hideMenuGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.menuView addGestureRecognizer:hideMenuGesture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method implementation

-(void)setupMenuView{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // Setup the background view.
    
    CGRect backgroundRect = screenRect;
    self.backgroundView = [[UIView alloc] initWithFrame:backgroundRect];
    
    self.backgroundView.backgroundColor = [UIColor lightGrayColor];
    self.backgroundView.alpha = 0.0;
    [self.view addSubview:self.backgroundView];
    
    CGFloat navBarHeight =
        self.navigationController.navigationBar.bounds.size.height;
    
    CGFloat boundsHeight = screenHeight;
    
    /*
    if(orientation == UIInterfaceOrientationLandscapeLeft){
        
        NSLog(@"changing menu view for landscape");
        boundsHeight = screenWidth - 50;
    }else if(orientation == UIInterfaceOrientationLandscapeRight){
        NSLog(@"right orientation");
    }
     */
    
    boundsHeight = screenWidth - 50;
    
    // Setup the menu view.
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(-menuWidth,
                                                             navBarHeight + 20,
                                                             menuWidth,
                                                             boundsHeight - navBarHeight)];
    
    self.menuView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [self.view addSubview:self.menuView];
    
    // Setup the table view.
    self.menuTable = [[UITableView alloc] initWithFrame:self.menuView.bounds
                                                  style:UITableViewStylePlain];
    self.menuTable.backgroundColor = [UIColor clearColor];
    self.menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.menuTable.scrollEnabled = NO;
    self.menuTable.alpha = 1.0;
    
    self.menuTable.delegate = self;
    self.menuTable.dataSource = self;
    
    [self.menuTable reloadData];
    
    [self.menuView addSubview:self.menuTable];
}

       
-(void)handleGesture:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        
        [self toggleMenu:YES];
    }
    else{
        [self toggleMenu:NO];
    }
}

-(void)toggleMenu:(BOOL)shouldOpenMenu{
    [self.animator removeAllBehaviors];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    
    CGFloat gravityDirectionX = (shouldOpenMenu) ? 1.0 : -1.0;
    CGFloat pushMagnitude = (shouldOpenMenu) ? 20.0 : -20.0;
    CGFloat boundaryPointX = (shouldOpenMenu) ? menuWidth : -menuWidth;
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.menuView]];
    gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX, 0.0);
    [self.animator addBehavior:gravityBehavior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat yBound = screenHeight;
    
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        yBound = screenWidth;
    }
    
    [collisionBehavior addBoundaryWithIdentifier:@"menuBoundary"
                                       fromPoint:CGPointMake(boundaryPointX, 20.0)
                                         toPoint:CGPointMake(boundaryPointX,yBound)];
    
    [self.animator addBehavior:collisionBehavior];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.menuView]
                                                                    mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.magnitude = pushMagnitude;
    [self.animator addBehavior:pushBehavior];
    
    UIDynamicItemBehavior *menuViewBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.menuView]];
    menuViewBehavior.elasticity = 0.4;
    [self.animator addBehavior:menuViewBehavior];
    
    self.backgroundView.alpha = (shouldOpenMenu) ? 0.5 : 0.0;
}

#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *menuOptionText = @"";
    switch (indexPath.row) {
        case 0:
            menuOptionText = @"Home";
            break;
        case 1:
            menuOptionText = @"Request Song";
            break;
        case 2:
            menuOptionText = @"Radio Staff";
            break;
        default:
            break;
    }
    
    cell.textLabel.text = menuOptionText;
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:13.0];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    switch (indexPath.row) {
        case 0: {
            HomeViewController *home = [HomeViewController new];
            [self.navigationController setViewControllers:@[home]];
        }
            break;
        case 1: {
            SongRequestViewController *sr = [SongRequestViewController new];
            [self.navigationController setViewControllers:@[sr]];
        }
            break;
            
        case 2: {
            StaffViewController *staff = [StaffViewController new];
            //[self.navigationController pushViewController:staff animated:YES];
            [self.navigationController setViewControllers:@[staff]];
        }
        default:
            break;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        NSLog(@"Landscape left");
        [self setupMenuView];
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        NSLog(@"Landscape right");
        [self setupMenuView];
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        NSLog(@"Portrait");
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        NSLog(@"Upside down");
    }
}

@end
