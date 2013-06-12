//
//  FightLayer.m
//  RunFighter
//
//  Created by Joseph Mordetsky on 4/25/13.
//
//

#import "FightLayer.h"
    
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
        [self tileMapAndHero];
        _baddies = [[NSMutableArray alloc] init];
        [self makeBaddies];
    }

    return self;
}


- (void) makeBaddies{
    //make N baddies, place them in a circle around ryu in idle
    //as we add sprites, check memory increase
    //as we add sprite states, check memory increase
    //as we add sprite, check framerate damage
    //as we add sprite off screen, check framerate damage
    int numBaddies = 80;
    for (int i=0; i<numBaddies; i++){
        int sliceSize = 360/numBaddies; //size of slice
        [self makeAndPlaceBaddy: sliceSize*i];
    }
}

- (void) makeAndPlaceBaddy:(int) angle{
    //make a baddy
    JCSprite *baddy = [[JCSprite alloc] initWithPlist:@"wizard.plist" Sheet:@"wizard.png" andInitialState:@"wizard.Idle.1.new.png"];
    
    //define idle
    JCSpriteDefEntry *idle = [[JCSpriteDefEntry alloc] init];
    idle.state = stateIdle;
    idle.nameFormat = @"wizard.Idle.%d.new.png";
    idle.frames = 24;
    idle.delay = 0.03f;
    idle.type = AnimationTypeLoop;
    
    
    //define walk
    JCSpriteDefEntry *run = [[JCSpriteDefEntry alloc] init];
    run.state = stateWalking;
    run.nameFormat = @"wizard.Run.%d.new.png";
    run.frames = 24;
    run.delay = 0.03f;
    run.type = AnimationTypeLoop;


    //add idle to baddy
    [baddy addDef:idle];
    [baddy addDef:run];
    
    //set in relation to ryu
    baddy.position = [self getSpotWithLocation:_ryu.position andAngle:angle];
    
    //add as a child
    [self addChild:baddy.batch];
    
    
    baddy.idle = stateIdle;
    baddy.moving = stateWalking;

    [baddy setState:stateIdle];
    
    //capture our baddies
    [_baddies addObject:baddy];

}

-(CGPoint) getSpotWithLocation: (CGPoint) location andAngle:(int) angle{
    //follow ryu, move to a position in the circle around where ryu is going
    float a = angle*(180/M_PI); //angle to rads
    int r = 200; //hard coded radius @ 200
    int x = location.x + r * cos(a);
    int y = location.y + r * sin(a);
    return ccp(x,y);
}

- (void) tileMapAndHero{
    self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"mymap.tmx"];
    self.background = [_tileMap layerNamed:@"Background"];
    [self addChild:_tileMap z:-1];
    
    _ryu = [[JCSprite alloc] initWithPlist:@"ryu-packed.plist" Sheet:@"ryu-packed.png" andInitialState:@"stance00.png"];
    
    _ryu.batch.tag = 2;
    
    //replace with
    
    CGPoint spawn = [self getHeroSpawn];
    [self centerOn:spawn];
    
    //calc ground
    int ground =  ([_ryu boundingBox].size.height/2) + 25;
    spawn.y += ground;
    _ryu.position = spawn;
    _ryu.tag = 1;
    
    self.isTouchEnabled = YES;
    
    JCSpriteDefEntry *idle = [[JCSpriteDefEntry alloc] init];
    idle.state = stateIdle;
    idle.nameFormat = @"stance0%d.png";
    idle.frames = 9;
    idle.delay = 0.1f;
    idle.type = AnimationTypeLoop;
    [_ryu addDef:idle];
    
    JCSpriteDefEntry *walk =  [[JCSpriteDefEntry alloc] init];
    walk.state = stateWalking;
    walk.nameFormat = @"walkf0%d.png";
    walk.frames = 9;
    walk.delay = 0.1f;
    walk.type = AnimationTypeLoop;
    [_ryu addDef:walk];
    
    JCSpriteDefEntry *punch =  [[JCSpriteDefEntry alloc] init];
    punch.state = statePunching;
    punch.nameFormat = @"walkf0%d.png";
    punch.frames = 9;
    punch.delay = 0.1f;
    punch.type = AnimationTypeOnce;
    [_ryu addDef:punch];
    
    [self addChild:_ryu.batch];
    _ryu.idle = stateIdle;
    _ryu.moving = stateWalking;
    [_ryu setState:stateIdle];
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

    CGPoint touchLocation = [self convertTouchToNodeSpace:_currentTouch];
    [_ryu moveTo:touchLocation withState:stateWalking callbackTarget:self onComplete:@selector(ryuMoveEnded)];

    
    [self moveBaddies];
    [self schedule:@selector(updateFunction)];
}

- (void) moveBaddies{

    CGPoint touchLocation = [self convertTouchToNodeSpace:_currentTouch];
    int sliceSize = 360/[_baddies count]; //size of slice
    int count = 0;
    for (JCSprite *baddy in _baddies)
    {
        // Move this baddy to his circle spot near where ryu is headed
        CGPoint circleSpot = [self getSpotWithLocation:touchLocation andAngle:sliceSize*count];
        count++;
        [baddy moveTo:circleSpot withState:stateWalking];
    }
}

- (void) updateFunction {
    [self centerOn:_ryu.position];
}

- (void) ryuMoveEnded{
    [self unschedule:@selector(updateFunction)];
    if (_currentTouch!=nil){
        [self moveHandler];
    }else{
        NSLog(@"stopping");
        [_ryu setState:stateIdle];
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
