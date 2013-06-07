//
//  CommonProtocols.h
//  RunFighter
//
//  Created by Joseph Mordetsky on 5/29/13.
//
//

#ifndef RunFighter_CommonProtocols_h
#define RunFighter_CommonProtocols_h

@protocol BackgroundFunctionsDelegate

-(CGPoint) getHeroSpawn;
-(void) centerOn:(CGPoint) point;


@end


#endif
