//
//  Backgrund.m
//  RunFighter
//
//  Created by Joseph Mordetsky on 4/24/13.
//
//

#import "Background.h"

@interface Background()

@property (strong) CCTMXTiledMap *tileMap;
@property (strong) CCTMXLayer *background;

@end

@implementation Background

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

-(id)init{
    self = [super init];
    if (self != nil){
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"mymap.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        [self addChild:_tileMap z:-1];
    }
    return self;
}
@end
