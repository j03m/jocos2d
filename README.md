jocos2d
=======

* What is Jocos2d? 

It's Abstraction on top of cocos2d for faster game prototyping. 

* What makes it faster? 

Really just semantics. Jocos let's just define a sprite from a given plist and packed png and trigger animation changes via a simple setState call. For example instead of invoking actions you and very simply:


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
    
    //add as a child to my layer
    [self addChild:baddy.batch];
        
    baddy.idle = stateIdle;
    baddy.moving = stateWalking;

    [baddy setState:stateIdle];



Moving around is also super simple. You just tell JCSprite where to go and how to look while it moves:

    CGPoint touchLocation = [self convertTouchToNodeSpace:_currentTouch];
    [_ryu moveTo:touchLocation withState:stateWalking andVelocity:25.0 callbackTarget:self onComplete:@selector(ryuMoveEnded)];

* Why is it called Jocos2d?

j03m + cocos2d = jocos2d 

Sure, terrible joke. 

