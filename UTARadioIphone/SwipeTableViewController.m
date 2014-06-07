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
#import "SocialViewController.h"
#import "ContactUsViewController.h"

#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <AVFoundation/AVFoundation.h>

#define menuWidth 150.0

typedef NS_ENUM(NSInteger, Orientation){
    PORTRAIT,
    LANDSCAPE
};

@interface SwipeTableViewController(){
    AudioPlayerSingleton *player;
    
    UISwipeGestureRecognizer *showMenuGesture;
    UISwipeGestureRecognizer *hideMenuGesture;
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    NSLog(@"remoteControlReceivedWithEvent");
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            NSLog(@"PlayerPause");
            [player togglePlayPause];
            break;
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"play");
            [player togglePlayPause];
            break;
        case UIEventSubtypeRemoteControlPause:
            NSLog(@"Pause");
            [player togglePlayPause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!player)
        player = [AudioPlayerSingleton singletonInstance];
    
    [self.view addSubview: [player createBottomToolbar]];
    
	//Create the side menu
    [self setupMenuView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    showMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    showMenuGesture.direction = UISwipeGestureRecognizerDirectionRight;
    showMenuGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:showMenuGesture];
   
    //customizing the navigation bar
    [self customizeNavBar];
}

- (void)customizeNavBar{
    //Set the nav bar attributes
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:47.0/255 green:152.0/255 blue:1.0 alpha:1]];
    
    //Set the title attributes
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method implementation

-(void)setupMenuView{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft
       || orientation == UIInterfaceOrientationLandscapeRight){
        
        [self changeMenuViewOrientation:LANDSCAPE];
    }else{
         [self changeMenuViewOrientation: PORTRAIT];
    }
}

- (void)changeMenuViewOrientation: (Orientation) o{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    
    //[self.menuView removeFromSuperview];
    
    CGRect frameRect = CGRectMake(0, 0, 0, 0);
    
    if(o == LANDSCAPE){
        CGRect backgroundLandscape = CGRectMake(0,0, screenHeight, screenWidth);
        self.backgroundView.frame = backgroundLandscape;
        
        CGRect landScapeRect = CGRectMake(-menuWidth,
                                          navBarHeight+20,
                                          menuWidth,
                                          screenWidth-navBarHeight);
        
        frameRect = landScapeRect;
    }else{
        CGRect backgroundPortrait = CGRectMake(0,0, screenWidth, screenHeight);
        self.backgroundView.frame = backgroundPortrait;
        
        CGRect portraitRect = CGRectMake(-menuWidth,
                                         navBarHeight+20,
                                         menuWidth,
                                         screenHeight-navBarHeight);
        frameRect = portraitRect;
    }
    
    [self.menuView removeFromSuperview];
        
    self.menuView = [[UIView alloc] initWithFrame:frameRect];
    
    //self.menuView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.menuView.backgroundColor = [UIColor lightGrayColor];
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
    
    if(hideMenuGesture){
        [self.menuView addGestureRecognizer:hideMenuGesture];
    }else{
        hideMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        hideMenuGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.menuView addGestureRecognizer:hideMenuGesture];
        [self.view addGestureRecognizer:hideMenuGesture];
    }
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
    menuViewBehavior.elasticity = 0.0;
    [self.animator addBehavior:menuViewBehavior];
    
    self.backgroundView.alpha = (shouldOpenMenu) ? 0.5 : 0.0;
}

#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
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
        case 3:
            menuOptionText = @"Social";
            break;
        case 4:
            menuOptionText = @"Contact Us";
            break;
        default:
            break;
    }
    
    cell.textLabel.text = menuOptionText;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:13.0];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0: {
            HomeViewController *home = [HomeViewController new];
            [self.navigationController setViewControllers:@[home]];
        }
            break;
        case 1: {
            SongRequestViewController *sr= [SongRequestViewController new];
            [self.navigationController setViewControllers:@[sr]];
        }
            break;
        case 2: {
            StaffViewController *staff = [StaffViewController new];
            [self.navigationController setViewControllers:@[staff]];
        }
        case 3: {
            SocialViewController *social = [SocialViewController new];
            [self.navigationController setViewControllers:@[social]];
        }
        case 4:{
            ContactUsViewController *contactUs = [ContactUsViewController new];
            [self.navigationController setViewControllers:@[contactUs]];
        }
        default:
            break;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self toggleMenu:NO];
        [player switchBottomToolbarToLandscape];
    }else{
        [self toggleMenu:NO];
        [player switchBottomToolbarToPortrait];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
     if(orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight){
         [self changeMenuViewOrientation: LANDSCAPE];
     }else{
         [self changeMenuViewOrientation: PORTRAIT];
     }
}

- (void)setNowPlayingWithSongTitle: (NSString *)songTitle andArtist: (NSString *)artist{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if(playingInfoCenter){
         NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        [songInfo setObject:songTitle forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:artist forKey:MPMediaItemPropertyArtist];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}
@end
