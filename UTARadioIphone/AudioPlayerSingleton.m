//
//  AudioPlayerSingleton.m
//  UTARadioIphone
//
//  Created by James Fielder on 6/2/14.
//  Copyright (c) 2014 com.mobi. All rights reserved.
//

#import "AudioPlayerSingleton.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AudioPlayerSingleton(){
    AVPlayer *player;
    
    //Bottom Toolbar
    UIToolbar *toolBar;
    UIBarButtonItem *playButton;
    UIBarButtonItem *pauseButton;
}

@end

@implementation AudioPlayerSingleton

+ (id) singletonInstance{
    static AudioPlayerSingleton *singletonIns = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonIns = [[self alloc] init];
    });
    return singletonIns;
}

- (id)init {
    if (self = [super init]) {
        NSString *stringurl = @"http://webmedia-2.uta.edu:1935/uta_radio/live/playlist.m3u8";
        NSURL *url = [NSURL URLWithString:stringurl];
        
        AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        player = [AVPlayer playerWithPlayerItem:playerItem];
        player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        //[player play];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *pItem = (AVPlayerItem *)object;
        if (pItem.status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"can play now");
            [self playpause];
        }
    }
}

- (void)playpause
{
    if ([self isPlaying]) {
        [self showPauseButton];
    } else {
        [self showPlayButton];
    }
}

- (IBAction)play: (id)sender{
    [player play];
    [self showPauseButton];
}

- (IBAction)pause: (id)sender{
    [player pause];
    [self showPlayButton];
}

- (void)showPauseButton
{
    NSLog(@"%@", [toolBar items]);
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolBar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:pauseButton];
    [toolbarItems removeObject:playButton];
    toolBar.items = toolbarItems;
}

- (void)showPlayButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolBar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:playButton];
    [toolbarItems removeObject:pauseButton];
    toolBar.items = toolbarItems;
}

- (BOOL)isPlaying
{
    return [player rate] != 0.f;
}

- (UIToolbar *) createBottomToolbar{
    if(!toolBar){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        CGRect frame = CGRectMake(0,screenHeight-44,screenWidth,44);
        
        toolBar = [[UIToolbar alloc] initWithFrame:frame];
        playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play:)];
        pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause:)];
        UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        MPVolumeView *volView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
        //MPVolumeView *volView = [[MPVolumeView alloc] init];
        volView.showsRouteButton = NO;
        UIBarButtonItem *volSliderAsToolbarItem = [[UIBarButtonItem alloc] initWithCustomView:volView];
        
        [toolBar setItems: @[playButton,pauseButton,flexiSpace,volSliderAsToolbarItem]];
    }
    //[self.view addSubview:toolBar];
    return toolBar;
}


@end
