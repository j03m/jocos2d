//
//  JocosSprite.h
//  RunFighter
//
//  Created by Joseph Mordetsky on 6/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import "cocos2d.h"
#import "JCSpriteDefEntry.h"

@interface JCSprite : CCSprite {}
@property (nonatomic, retain) NSMutableDictionary* animations;
@property (nonatomic, retain) CCSpriteBatchNode *batch;
@property (nonatomic) int state;
@property (nonatomic) int idle;
@property (nonatomic) int moving;
@property (nonatomic, strong) CCAction *currentMove;
@property int nextState;
- (void) setState: (int) state;
- (void) animationDone;
- (void) addDef:(JCSpriteDefEntry *) entry;
- (id) initWithPlist:(NSString *) plist Sheet:(NSString *) sheet andInitialState: (NSString *) initialState;
- (void) moveTo:(CGPoint) location withState:(int) movementState andVelocity:(float) velocity callbackTarget:target onComplete:(SEL) callback;
- (void) moveTo:(CGPoint) location withState:(int) movementState andVelocity:(float) velocity;
//move to

@end
