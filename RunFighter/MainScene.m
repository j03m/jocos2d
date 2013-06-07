//
//  MainScene.m
//  RunFighter
//
//  Created by Joseph Mordetsky on 4/24/13.
//
//

#import "MainScene.h"
#import "Background.h"
#import "FightLayer.h"

@implementation MainScene
-(id) init{
    self = [super init];
    if (self != nil){
//        Background *backgroundLayer = [Background node];
        FightLayer *fightLayer = [FightLayer node];
//        [self addChild:backgroundLayer z:0];
        [self addChild:fightLayer z:5];
        
    }
    return self;
}

@end
