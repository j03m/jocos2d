//
//  JCSpriteDefEntry.h
//  RunFighter
//
//  Created by Joseph Mordetsky on 6/6/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AnimationType.h"

@interface JCSpriteDefEntry : NSObject
@property (assign) int state;
@property (assign) int transitionTo;
@property (assign) NSString *nameFormat;
@property (assign) int frames;
@property (assign) float delay;
@property (retain) CCAction * action;
@property (assign) AnimationType type;



@end
