//
//  FightLayer.h
//  RunFighter
//
//  Created by Joseph Mordetsky on 4/25/13.
//
//

#import "CCLayer.h"
#import "jocos2d.h"
#import "CommonProtocols.h"


typedef enum {
    stateIdle =0,
    stateWalking =1,
    statePunching=2
} states;


@interface FightLayer : CCLayer
@property (nonatomic, strong) JCSprite *ryu;
@property (strong) CCTMXTiledMap *tileMap;
@property (strong) CCTMXLayer *background;
@property (assign) UITouch *currentTouch;
@property BOOL nextMove;
@property (nonatomic, strong) NSMutableArray *baddies;



@end

