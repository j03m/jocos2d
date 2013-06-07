//
//  FightLayer.h
//  RunFighter
//
//  Created by Joseph Mordetsky on 4/25/13.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "CommonProtocols.h"
@interface FightLayer : CCLayer
typedef enum {
    walking,
    idle,
} AnimationState;

@property (nonatomic, strong) CCSprite *ryu;
@property (nonatomic, strong) CCAction *ryuStanceAction;
@property (nonatomic, strong) CCAction *ryuWalkAction;
@property (nonatomic, strong) CCAction *ryuMoveAction;
@property (strong) CCTMXTiledMap *tileMap;
@property (strong) CCTMXLayer *background;
@property (assign) UITouch *currentTouch;
@property BOOL nextMove;

@property AnimationState state;
- (void) postInit;
@end

