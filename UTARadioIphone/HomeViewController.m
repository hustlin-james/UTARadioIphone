//
//  HomeViewController.m
//  UTARadioIphone
//
//  Created by James Fielder on 6/2/14.
//  Copyright (c) 2014 com.mobi. All rights reserved.
//

#import "HomeViewController.h"
#import "AudioPlayerSingleton.h"
#import "XMLReader.h"
#import "MarqueeLabel.h"


//Constants
#define MARQUEE_FONT_NAME @"Helvetica"
#define MARQUEE_FONT_SIZE 17.0
#define DEFAULT_MARQUEE_FRAME_WIDTH 250.0

#define DEFAULT_MARQUEE_TEXT @"You are listening to UTA Radio. Enjoy!"

@interface SwipeTableViewController()
- (void)setNowPlayingWithSongTitle: (NSString *)songTitle andArtist: (NSString *)artist;
@end

@interface HomeViewController (){
    //NSString *songStr;
    MarqueeLabel *marqueeLbl;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation HomeViewController

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
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Home";
    
    [self attachMarqueeLabel];
    [self retrieveNowPlaying];
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(retrieveNowPlaying)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) attachMarqueeLabel{
    marqueeLbl = [[MarqueeLabel alloc]
                  initWithFrame:CGRectMake(0, 0, DEFAULT_MARQUEE_FRAME_WIDTH, 20)
                  rate:80.0f andFadeLength:10.0f];
    
    CGPoint centerALittleBelow = self.contentView.center;
    centerALittleBelow.y = centerALittleBelow.y + 40;
    [marqueeLbl setCenter: centerALittleBelow];
    
    marqueeLbl.tag = 101;
    marqueeLbl.marqueeType = MLContinuous;
    marqueeLbl.animationCurve = UIViewAnimationOptionCurveLinear;
    marqueeLbl.continuousMarqueeExtraBuffer = 50.0f;
    marqueeLbl.numberOfLines = 1;
    marqueeLbl.opaque = NO;
    marqueeLbl.enabled = YES;
    marqueeLbl.shadowOffset = CGSizeMake(0.0, -1.0);
    marqueeLbl.textAlignment = NSTextAlignmentLeft;
    marqueeLbl.textColor = [UIColor colorWithRed:47.0/255.0 green:152.0/255 blue:1.0 alpha:1.000];
    marqueeLbl.backgroundColor = [UIColor clearColor];
    marqueeLbl.font = [UIFont fontWithName:MARQUEE_FONT_NAME  size:MARQUEE_FONT_SIZE];
    marqueeLbl.text = DEFAULT_MARQUEE_TEXT;
    
    [marqueeLbl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [self.contentView addSubview:marqueeLbl];
    
}

- (void) updateMarqueeLabel: (NSString *)str{
    
    if( ![str isEqualToString:marqueeLbl.text]){
        //NSLog(@"updating marquee label");
        
        UIFont *font = [UIFont fontWithName:MARQUEE_FONT_NAME size:MARQUEE_FONT_SIZE];
        CGRect textRect;
        NSDictionary *attributes = @{NSFontAttributeName: font};
        
        textRect.size = [str sizeWithAttributes:attributes];
        
         if(textRect.size.width < DEFAULT_MARQUEE_FRAME_WIDTH){
             marqueeLbl.frame = CGRectMake(0, 0, textRect.size.width+20, 20);
             if(!marqueeLbl.isPaused){
                 NSLog(@"pausing marquee label");
                 [marqueeLbl pauseLabel];
             }
         }else{
             marqueeLbl.frame = CGRectMake(0, 0, DEFAULT_MARQUEE_FRAME_WIDTH, 20);
             if(marqueeLbl.isPaused)
             [marqueeLbl unpauseLabel];
         }

        [marqueeLbl setText:str];
        CGPoint centerALittleBelow = self.contentView.center;
        centerALittleBelow.y = centerALittleBelow.y + 40;
        [marqueeLbl setCenter: centerALittleBelow];
    }
   
}

- (void) retrieveNowPlaying{
    dispatch_queue_t songInfoQueue = dispatch_queue_create("song info queue", NULL);
    dispatch_async(songInfoQueue, ^{
        [self retrieveNowPlayingOperation];
    });
  
}

- (void)retrieveNowPlayingOperation{
    NSString *infoUrl = @"http://radio.uta.edu/_php/nowplaying.php";
    NSURL  *url = [NSURL URLWithString:infoUrl];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSString *songTitle = @"";
    NSString *songArtist = @"";
    NSString *songStr = @"";
    
    if(urlData){
        //This is an XML String
        NSString *myString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSDictionary *dict=[[NSDictionary alloc]initWithDictionary:[XMLReader dictionaryForXMLString:myString error:nil]];
        
        songTitle = [[[dict objectForKey:@"nowplaying"] objectForKey:@"title"] objectForKey:@"text"];
        songArtist = [[[dict objectForKey:@"nowplaying"] objectForKey:@"artist"] objectForKey:@"text"];
        
        if(songArtist && songTitle && ![songArtist isEqualToString:@""] && ![songTitle isEqualToString:@""]){
            songStr=[@"" stringByAppendingFormat:@"%@ - By: %@", songTitle, songArtist];
        }else{
            songStr=DEFAULT_MARQUEE_TEXT;
            songArtist = @"";
            songTitle = @"";
        }
    }else{
        songStr=DEFAULT_MARQUEE_TEXT;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateMarqueeLabel:songStr];
        
        if(![songArtist isEqualToString:@""] && ![songTitle isEqualToString:@""]){
            [self setNowPlayingWithSongTitle:songTitle andArtist:songArtist];
        }else{
            [self setNowPlayingWithSongTitle:DEFAULT_MARQUEE_TEXT andArtist:@"UTA Radio"];
        }
    });
    
}

@end
