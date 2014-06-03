//
//  AudioPlayerSingleton.h
//  UTARadioIphone
//
//  Created by James Fielder on 6/2/14.
//  Copyright (c) 2014 com.mobi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
@protocol AudioPlayerDelegate <NSObject>
@required
- (void) isAVPlayerReady:(BOOL)ready;
@end
 */

@interface AudioPlayerSingleton : NSObject

//@property (nonatomic, weak) id<AudioPlayerDelegate> delegate;

+ (id) singletonInstance;
- (UIToolbar *) createBottomToolbar;
@end
