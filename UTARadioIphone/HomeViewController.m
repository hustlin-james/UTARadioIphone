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

@interface HomeViewController (){
    NSString *songStr;
}

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

- (void) retrieveNowPlaying{
    NSString *infoUrl = @"http://radio.uta.edu/_php/nowplaying.php";
    NSURL  *url = [NSURL URLWithString:infoUrl];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    if(urlData){
        //This is an XML String
        NSString *myString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        NSDictionary *dict=[[NSDictionary alloc]initWithDictionary:[XMLReader dictionaryForXMLString:myString error:nil]];
        NSString *songTitle = [[[dict objectForKey:@"nowplaying"] objectForKey:@"title"] objectForKey:@"text"];
        NSString *songArtist = [[[dict objectForKey:@"nowplaying"] objectForKey:@"artist"] objectForKey:@"text"];
        
        if(songArtist && songTitle){
            songStr=[songTitle stringByAppendingFormat:@"%@ - By: %@", songTitle, songArtist];
        }else{
            songStr=@"You are listening to UTA Radio";
        }
    }else{
        songStr=@"You are listening to UTA Radio";
    }
    
    NSLog(@"songStr: %@", songStr);
}

@end
