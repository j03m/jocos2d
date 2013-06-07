//
//  JocosSprite.h
//  RunFighter
//
//  Created by Joseph Mordetsky on 6/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jocos2d.h"
#import "JCSpriteDefEntry.h"
typedef enum {
    once,
    loop,
} AnimationType;


@interface JCSprite : CCSprite {}
@property (nonatomic, strong) NSMutableDictionary* animations;
@property (nonatomic, strong) CCSpriteBatchNode *batch;
- (void) setState: (NSString) state;
- (void) animationDone;
- (void) addDef:(JCSpriteDefEntry *) entry;
- (void) initWithPlist:(NSString *) plist Sheet:(NSString *) sheet andInitialState: (NString *) initialState;

//move to

@end
