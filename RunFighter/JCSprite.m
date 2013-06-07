//
//  JocosSprite.m
//  RunFighter
//
//  Created by Joseph Mordetsky on 6/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "jocos2d.h"


@implementation JCSprite

- (id) init{
    self = [super init];
    _animations = [NSMutableDictionary dictionary];
    return self;
}

- (void) initWithPlist:(NSString *) plist Sheet:(NSString *) sheet andInitialState:(NSString *) initialState{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
    _batch = [CCSpriteBatchNode batchNodeWithFile:sheet];
    self = [CCSprite spriteWithSpriteFrameName:initialState];
    
}


- (void) addDef:(JCSpriteDefEntry *) entry{
    //array for frames
    NSMutableArray *animationFrames = [NSMutableArray array];

    //loop through the frames using the nameFormat and init the animation
    for (int i=0; i<=entry.frames; i++) {
        NSString *theFrame = [NSString stringWithFormat:entry.nameFormat,i];
        [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:theFrame]];
    }
    
    //make the animation
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:entry.delay];

    //if the entry type is a loop create a forver action
    if (entry.type == AnimationType.loop){
        CCAction * action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        //set the action on the entry
        entry.action = action;
    }else{
        
        //otherwise assume a one play with animationDone as an ending func
        //we'll extend this with more types later. This is all I need right now
        CCFiniteTimeAction *action = [CCAnimate actionWithAnimation:animation];
        CCRepeat *repeatAction = [CCRepeat actionWithAction:action times:1];
        CCSequence *sequence = [CCSequence actionOne:repeatAction two:animationDone];
        //set the action on the entry
        entry.action = sequence;
    }
    //save the animation
    [_animations setObject: entry  forKey: entry.state];
}

- (void) animationDone{
    [setState state:_nextState];
}

- (void) setState: (NSString) state{
    //get the entry
    JCSpriteDefEntry *entry = [_animations objectForKey: state];
    //set the next transition state in case it's a 1 framer
    _nextState = entry.transitionTo;
    //run the action
    [self runAction:entry.action];
}


@end
