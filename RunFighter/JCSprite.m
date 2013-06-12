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
    NSAssert(true, @"call initWithPlist pls");
    return [super init];
}

- (id) initWithPlist:(NSString *) plist Sheet:(NSString *) sheet andInitialState:(NSString *) initialState{
    self = [super init];
        
    //todo only do this once for a sheet and plist pairing.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
    _batch = [CCSpriteBatchNode batchNodeWithFile:sheet];
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:initialState];
    [super initWithSpriteFrame:frame];
    [_batch addChild:self];
    _animations = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) addDef:(JCSpriteDefEntry *) entry{
    //array for frames
    NSMutableArray *animationFrames = [NSMutableArray array];

    //loop through the frames using the nameFormat and init the animation
    for (int i=0; i<entry.frames; i++) {                                                                                           
        NSString *theFrame = [NSString stringWithFormat:entry.nameFormat,i];
        [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:theFrame]];
    }
    
    //make the animation
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:entry.delay];

    //if the entry type is a loop create a forver action
    if (entry.type == AnimationTypeLoop){
        CCAction * action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        //set the action on the entry
        action.tag = entry.state;
        entry.action = action;
    }else{
        
        //otherwise assume a one play with animationDone as an ending func
        //we'll extend this with more types later. This is all I need right now
        CCFiniteTimeAction *action = [CCAnimate actionWithAnimation:animation];
        CCRepeat *repeatAction = [CCRepeat actionWithAction:action times:1];
        id animationComplete  = [CCCallFunc actionWithTarget:self selector:@selector(animationDone)];
        CCSequence *sequence = [CCSequence actionOne:repeatAction two:animationComplete];
        entry.action = sequence;
    }
    //save the animation
    NSNumber *actualKey = [NSNumber numberWithInt:entry.state];
    [_animations setObject:entry forKey:[actualKey stringValue]];
}


- (void) moveTo:(CGPoint) location withState:(int) movementState andVelocity:(float) velocity callbackTarget:target onComplete:(SEL) callback{
    CGPoint moveDifference = ccpSub(location, self.position);
    float distanceToMove = ccpLength(moveDifference);
    float moveDuration = distanceToMove / velocity;
    
    if (_state == _idle){
        [self setState:_moving];
    }else if (_state == _moving){ //we're already walking, stop and change direction
        [self stopAction:_currentMove];
    }
    
    //set up the move
    //convert to [ryu moveTo:position withState:state];
    CCMoveTo *moveAction = [CCMoveTo actionWithDuration:moveDuration position:location];
    _currentMove = [CCSequence actions:moveAction,[CCCallFunc actionWithTarget:target selector:callback], nil];
    [self runAction:_currentMove];

}

- (void) moveTo:(CGPoint) location withState:(int) movementState andVelocity:(float) velocity{

    CGPoint moveDifference = ccpSub(location, self.position);
    float distanceToMove = ccpLength(moveDifference);
    float moveDuration = distanceToMove / velocity;
    
    if (_state == _idle){
        [self setState:_moving];
    }else if (_state == _moving){ //we're already walking, stop and change direction
        [self stopAction:_currentMove];
    }
    
    //set up the move
    //convert to [ryu moveTo:position withState:state];
    CCMoveTo *moveAction = [CCMoveTo actionWithDuration:moveDuration position:location];
    _currentMove = [CCSequence actions:moveAction,[CCCallFunc actionWithTarget:self selector:@selector(moveEnded)], nil];
    [self runAction:_currentMove];

}

- (void) moveEnded{
    [self setState:_idle];
    [self stopAction:_currentMove];
}

- (void) animationDone{
    [self setState:_nextState];
}

- (void) setState: (int) state{
    //get the entry
    int currentState = _state;
    _state = state;
    
    JCSpriteDefEntry *startMe = [self objectForKey: _state];
    JCSpriteDefEntry *stopMe = [self objectForKey: currentState];
    
    if (startMe!=nil && stopMe!=nil){
        //set the next transition state in case it's a 1 framer
        _nextState = startMe.transitionTo; //save this for later
        //stop current action, start the next action
        [self stopAction:stopMe.action];
        [self runAction:startMe.action];
    }else{
        NSLog(@"Couldn't set state. The state you supplied was bad or the one the sprite is in was bad. I realize that this could be more helpful, but hey it's version .01");
    }
}

- (JCSpriteDefEntry*) objectForKey: (int)key{
    return [_animations objectForKey:[[NSNumber numberWithInt:key] stringValue] ];
}

@end
