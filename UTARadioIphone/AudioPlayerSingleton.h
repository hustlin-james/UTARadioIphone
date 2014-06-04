//
//  AudioPlayerSingleton.h
//  UTARadioIphone
//
//  Created by James Fielder on 6/2/14.
//  Copyright (c) 2014 com.mobi. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AudioPlayerSingleton : NSObject
+ (id) singletonInstance;
- (UIToolbar *) createBottomToolbar;
- (void) switchBottomToolbarToLandscape;
- (void) switchBottomToolbarToPortrait;
- (CGFloat)toolBarHeight;
@end
