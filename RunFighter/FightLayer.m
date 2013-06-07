//
//  FightLayer.m
//  RunFighter
//
//  Created by Joseph Mordetsky on 4/25/13.
//
//

#import "FightLayer.h"
#import "CommonProtocols.h"
    
//punch on a double click
//limit walk area
//jump and arc if tap is above a level
//walk on scrolling bg
//collider

//jocos2d - (possibly in cocos2dx)
//sprite lib
    //sprite from exten
    //change state - transitions, idle time
    //change pos
    //move to point, velocity etc
    //flip direction
    //spawn
    //pulse AI method
    //transition animations?
    //composites?

//other stuff
    //impressions to #1 + cost
    //Google analytics for stats?
    //ad impression data - how much $$
    //



@implementation FightLayer

-(id)init{
    self = [super init];
    if(self != nil){

        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"mymap.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        [self addChild:_tileMap z:-1];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ryu-packed.plist"];
        CCSpriteBatchNode *ryuBatch = [CCSpriteBatchNode batchNodeWithFile:@"ryu-packed.png"];
        CCSprite *ryuSprite = [CCSprite spriteWithSpriteFrameName:@"stance00.png"];
        //CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        //the bottom of the sprite should be 50px from the bottom of the screen. Which means the middle of the sprite should be 1/2 the sprites height from the bottom of the screen + an additional 50
        
        //replace with

        CGPoint spawn = [self getHeroSpawn];
        [self centerOn:spawn];
        
        //calc ground
        int ground =  ([ryuSprite boundingBox].size.height/2) + 25;
        spawn.y += ground;
        ryuSprite.position = spawn;
        ryuSprite.tag = 1;
        [ryuBatch addChild:ryuSprite];
        
        self.isTouchEnabled = YES;
        ryuBatch.tag = 2;
        [self addChild:ryuBatch];
        
        //get ryu stance frames
        NSMutableArray *ryuStanceFrames = [NSMutableArray array];
        for (int i=0; i<=9; i++) {
            NSString *theFrame = [NSString stringWithFormat:@"stance0%d.png",i];
            [ryuStanceFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:theFrame]];
        }
        
        NSMutableArray *ryuWalkForwardFrames = [NSMutableArray array];
        for (int i=0; i<=9; i++) {
            NSString *theFrame = [NSString stringWithFormat:@"walkf0%d.png",i];
            [ryuWalkForwardFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:theFrame]];
        }
        
        //put Ryu into a stance
        CCAnimation *ryuStance = [ CCAnimation animationWithSpriteFrames:ryuStanceFrames delay:0.1f];
        
        CCAnimation *ryuWalkForward = [ CCAnimation animationWithSpriteFrames:ryuWalkForwardFrames delay:0.1f];
        
        self.ryuStanceAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:ryuStance]];
        self.ryuWalkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:ryuWalkForward]];
        
        self.state = idle;
        [ryuSprite runAction:self.ryuStanceAction];
        

    }

    return self;
}



- (void) registerWithTouchDispatcher{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate: self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent * )event{
    NSLog(@"began");
 
    _currentTouch = touch;
    [self moveHandler];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    NSLog(@"moved");
    _currentTouch = touch;
    [self schedule:@selector(moveHandler) interval:.05 repeat:1 delay:0];
    
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent * )event{
    NSLog(@"end");
    _currentTouch = nil;
}

- (void) moveHandler {
    CCSpriteBatchNode *ryuBatch = (CCSpriteBatchNode*)[self getChildByTag:2];
    CCSprite *ryu = (CCSprite *)[ryuBatch getChildByTag:1];
    CGPoint touchLocation = [self convertTouchToNodeSpace:_currentTouch];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    float bearVelocity = screenSize.width / 3.0;
    CGPoint moveDifference = ccpSub(touchLocation, ryu.position);
    float distanceToMove = ccpLength(moveDifference);
    float moveDuration = distanceToMove / bearVelocity;
    
    if (self.state == idle){
        [ryu stopAction:self.ryuStanceAction];
        [ryu runAction:self.ryuWalkAction];
        self.state = walking;
    }else if (self.state == walking){ //we're already walking, stop and change direction
        [ryu stopAction:self.ryuMoveAction];
    }
    
    //set up the move
    CCMoveTo *moveAction = [CCMoveTo actionWithDuration:moveDuration position:touchLocation];
    //Use a in/out sin ease
    
    
    self.ryuMoveAction = [CCSequence actions:moveAction,[CCCallFunc actionWithTarget:self selector:@selector(ryuMoveEnded)], nil];
    [ryu runAction:self.ryuMoveAction];
    [self schedule:@selector(updateFunction)];

}

- (void) updateFunction {

    CCSpriteBatchNode *ryuBatch = (CCSpriteBatchNode*)[self getChildByTag:2];
    CCSprite *ryu = (CCSprite *)[ryuBatch getChildByTag:1];
    [self centerOn:ryu.position];
    
}

- (void) ryuMoveEnded{
    CCSpriteBatchNode *ryuBatch = (CCSpriteBatchNode*)[self getChildByTag:2];
    CCSprite *ryu = (CCSprite *)[ryuBatch getChildByTag:1];
    [self unschedule:@selector(updateFunction)];
    if (_currentTouch!=nil){
        [self moveHandler];
    }else{
        NSLog(@"stopping");
        [ryu stopAction:self.ryuWalkAction];
        [ryu stopAction:self.ryuMoveAction];
        [ryu runAction:self.ryuStanceAction];
        self.state = idle;
    }
}

- (CGPoint)getHeroSpawn{
    //put the hero spawn code from blog here
    CCTMXObjectGroup * objectGroup = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    
    NSDictionary *spawnPoint = [objectGroup objectNamed:@"SpawnPoint"];
    int x = [spawnPoint[@"x"] integerValue];
    int y = [spawnPoint[@"y"] integerValue];
    
    return ccp(x,y);
    
}

- (void) centerOn:(CGPoint) point{
    [self setViewPointCenter:point];
}

- (void)setViewPointCenter:(CGPoint) position {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int x = MAX(position.x, winSize.width/2);
    int y = MAX(position.y, winSize.height/2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}


@end
