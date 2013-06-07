//
//  JCSpriteDefEntry.h
//  RunFighter
//
//  Created by Joseph Mordetsky on 6/6/13.
//
//

#import <Foundation/Foundation.h>
#import "jocos2d.h"

@interface JCSpriteDefEntry : NSObject{}



@property (assign) NSString *state;
@property (assign) NSString *nameFormat;
@property (assign) int frames;
@property (assign) float delay;
@property (retain) CCAction * action;
@property (assign) AnimationType type;



@end
