//
//  GameScene.m
//  Pick a SeaObject
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "GameScene.h"
#import "MainMenuScene.h"
#import "GameModel.h"
#import "GameSky.h"
#import "GameSea.h"
#import "SeaHelper.h"

@interface GameScene()
{

    
    GameManager* gameManager;
    GameModel* model;
    CGSize winSize;
    GameSky* sky;
    GameSea* sea;
    CCLabelTTF* debugLabel;
    CCLabelBMFont* timeLeftLabel;
    CCLabelBMFont* caughtSeaObjectLabel;
}
    
+ (CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor;
- (void) createMenu;
- (void)showConfirmAlert;
@end

@implementation GameScene

const ccTime fixed_dt_ = 1.0f/60.0f;

+(CCScene *) scene
{

    
    //CGPoint p = [SolarUtil sunPosition:[SolarUtil dayOfYear:[NSDate date]] year:2012 hour:8 lat:46.5f lng:6.5f];
    //NSLog(@"hour: 7 az:%f el:%f",p.x*kmPIUnder180,p.y*kmPIUnder180);
 	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    layer->gameManager = [GameManager sharedGameManager];
    [layer prepareLevel];
	return scene;
}

-(id)init
{
    
    self = [super init];
    if (self != nil)
    {
        self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
        srandom(time(NULL));
        timer_accumulator_ = 0;
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        
        winSize = [CCDirector sharedDirector].winSize;
        model = [GameModel node];
        [self addChild:model];
        sky = [[GameSky alloc] initWithModel:model];
        sea = [[GameSea alloc] initWithModel:model];
        sea.seaObjectEventReceiverObject = self;
       
        
        model->world->SetDebugDraw(m_debugDraw);
        
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        		flags += b2Draw::e_jointBit;
        		flags += b2Draw::e_aabbBit;
        		flags += b2Draw::e_pairBit;
        		flags += b2Draw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags);
        
        //initialize progress bar
        model->catchingTimer = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile: @"arc.png"]];
        model->catchingTimer.type = kCCProgressTimerTypeRadial;
        model->catchingTimer.percentage = 10;
        model->catchingTimer.opacity = 0;
        model->catchingTimer.color = ccc3(10,210,50);
        [self addChild:model->catchingTimer z:10 tag:20];
        [model->catchingTimer setPosition:ccp(100, 100)];
        
        
        debugLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12];
        debugLabel.anchorPoint = ccp(0,0);
        debugLabel.opacity = 0;
        debugLabel.position = ccp(0,winSize.height-20);
        [self addChild:debugLabel z:100];
        
        timeLeftLabel = [CCLabelBMFont labelWithString:@"99:99" fntFile:@"font-score-time.fnt"];
        
		timeLeftLabel.anchorPoint = ccp(0,1.0f);
        timeLeftLabel.position = ccp(winSize.width*0.01f, winSize.height);
        [self addChild:timeLeftLabel z:100];
		
        caughtSeaObjectLabel = [CCLabelBMFont labelWithString:@"%03d Caught" fntFile:@"font-level.fnt" width:350 alignment:kCCTextAlignmentRight];
		caughtSeaObjectLabel.anchorPoint = ccp(1.0f,1.0f);
        caughtSeaObjectLabel.position = ccp(winSize.width, winSize.height);
        [self addChild:caughtSeaObjectLabel z:100];
        
        
        [self addChild:model->bgLayer z:0];        
        [self addChild:model->seaLayer z:1];
        [self createMenu];
        
        
        
        
        return self;
    }
    return nil;
}



- (void) prepareLevel
{
    model->gameSpeed_ = [gameManager.settings.gameSpeed floatValue];
    model->level = gameManager->gameState.currentLevel;
    model->difficulty = [gameManager.settings.difficulty intValue];
    int64_t score = [gameManager.settings getLevelTopScore:model->level];
    {
        model->seaObjectSpawnCounter = 0;
        model->startCatchSeaObject = NO;
        model->catchSeaObjectCounter = 0;
        model->catchSeaObjectTime = 1.0f;
        model->currentSeaObjectBeingCaught = NULL;
    }
    
    
    //level specific stuff
    //static int timeLeftDiff[3] = {0,0,0 };
    static int timeLeftLevel[5] = {180,150,140,130,120};
    assert(model->level >=0 && model->level <= 4);
    assert(model->difficulty >=0 &&  model->difficulty <= 2);
    model->timeLeft_ = timeLeftLevel[model->level] - ( model->difficulty*10*(model->level+1));
    model->fishAliveTime = 5.5f - (model->difficulty*1.25);
    model->specialsAliveTime = 3.0f - (model->difficulty*0.75);
    model->seaObjectSpawnTime = 2.0f;
    
    {
        NSString* difficultyStr;
        switch ([gameManager.settings.difficulty intValue])
        {
            case 0:
                difficultyStr = @"(easy mode)";
                break;
            case 1:
                difficultyStr = @"(medium mode)";
                break;
            case 2:
                difficultyStr = @"(hard mode)";
                break;
        }
        CCLayerColor* fsLayer = [CCLayerColor node];
        fsLayer.color = ccc3(0,0,0);
        fsLayer.opacity = 255;
        CCLabelBMFont* levelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Level %d\n%@",(model->level+1),difficultyStr] fntFile:@"font-title1.fnt" width:winSize.width alignment:kCCTextAlignmentCenter];
        [levelLabel setScale:1];
        levelLabel.position = ccp(winSize.width/2, winSize.height/2);
        [fsLayer addChild:levelLabel];
        [self addChild:fsLayer z:100];
		
        {
            id delay1 = [CCDelayTime actionWithDuration:2.0f];
            id fade1 = [CCFadeOut actionWithDuration:1.0f];
            id callfunc = [CCCallFunc actionWithTarget:self selector:@selector(startGame)];
            id seqAction1 = [CCSequence actions:delay1,callfunc,fade1,nil];
            [fsLayer runAction:seqAction1];
        }
        {
            id delay1 = [CCDelayTime actionWithDuration:2.0f];
            id fade1 = [CCFadeOut actionWithDuration:1.0f];
            id seqAction2 = [CCSequence actions:delay1,fade1,nil];
            [levelLabel runAction:seqAction2];
        }
    }
    
    //random time of day
    model->timeOfDay_ = CCRANDOM_0_1()*24*timeRatio;
    [model randomizeWeather];

}

- (void) completeLevel
{
    [gameManager.settings setLevel:model->level TopScore:model->score];
    [self stopGame];
    [gameManager runSceneWithID:kLevelCompleteScene];
}



- (void) startGame
{
    memset(&gameManager->counters,0,sizeof(gameManager->counters));
    //[gameManager playBackgroundTrack:@"sea-waves-bg.aifc"];
    [gameManager playBackgroundTrack:@"water1.wav"];
    [self update:fixed_dt_];
    [self scheduleUpdate];
}

- (void) pauseGame
{
    [model->rainEmitter pauseSchedulerAndActions];
    [self pauseSchedulerAndActions];
}

- (void) resumeGame
{
    [model->rainEmitter resumeSchedulerAndActions];
    [self resumeSchedulerAndActions];
}

- (void) stopGame
{
    [self pauseGame];
    [[GameManager sharedGameManager] playBackgroundTrack:nil];
}

+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	[label setColor:cor];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint center = ccp(label.texture.contentSize.width/2+size, label.texture.contentSize.height/2+size);
	[rt begin];
	for (int i=0; i<360; i+=15)
	{
		[label setPosition:ccp(center.x + sin(CC_DEGREES_TO_RADIANS(i))*size, center.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[rt setPosition:originalPos];
	return rt;
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
    
	// Reset Button
    CCMenuItemImage* quitItem = [CCMenuItemImage itemWithNormalImage:@"exit-icon.png" selectedImage:@"exit-icon.png" block:^(id sender) {
	//CCMenuItemLabel *quitItem = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender){
		//[[CCDirector sharedDirector] replaceScene: [GameScene node]];
        [self showConfirmAlert];
	}];
	quitItem.anchorPoint = ccp(1.0f,0);
    quitItem.color = ccc3(255,255,255);
	
    
    //CCLabelTTF* label = [CCLabelTTF labelWithString: @"Some Text"
     //                              dimensions:CGSizeMake(305,179) hAlignment:kCCTextAlignmentLeft
     //                                fontName:@"Arial" fontSize:23];
    //[label setPosition:ccp(167,150)];
    //[label setColor:ccWHITE];
    //CCRenderTexture* stroke = [GameScene createStroke:label  size:2  color:ccc3(255,0,255)];
    //[self addChild:stroke];
    //[self addChild:label];
    //CCMenuItemSprite* spriteItem = [CCMenuItemSprite itemWithNormalSprite:[stroke sprite] selectedSprite:label];
	
    
    CCMenu *menu = [CCMenu menuWithItems:quitItem, nil];
	
	[menu alignItemsVertically];
	[menu setPosition:ccp(winSize.width,0)];
    
    [self addChild: menu z:100];
}

- (void) draw
{
    [super draw];

    //sky is covering this
    float ampX = winSize.width/2;
    float ampY = winSize.height/2;
    CGPoint screenCenter = CGPointMake(ampX,ampY);
    CGPoint direction = ccpNormalize(ccpSub(screenCenter,model->sunSprite.position));
    float dist = ccpDistance(model->sunSprite.position,screenCenter);
    
    CGPoint flarePoint = ccpAdd(model->sunSprite.position,ccpMult(direction,dist*0.5f));
    ccDrawColor4B(255, 0, 255, 255);
    ccDrawCircle(flarePoint, 40, 360, 20, 0);//(model->sunSprite.position,));
    ccDrawColor4B(255, 255, 255, 255);
    ccDrawLine(model->sunSprite.position,screenCenter);
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    kmGLPushMatrix();
	model->world->DrawDebugData();
	kmGLPopMatrix();
}




- (void) innerUpdate: (ccTime) dt
{
    if (model->timeLeft_ <= 9.5)
        timeLeftLabel.color = ccc3(255, 0, 0);
    
    if (model->timeLeft_ < 0.7)
    {
        [self completeLevel];

    }
    
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    [debugLabel setString:[NSString stringWithFormat:@"time of day: %03.3f",model->timeOfDay_/timeRatio]];
    [timeLeftLabel setString:[NSString stringWithFormat:@"%.0f",model->timeLeft_]];
    [caughtSeaObjectLabel setString:[NSString stringWithFormat:@"%llu",model->score]];
    
    
    
    [sky update:dt];
    [sea update:dt];
    
   
    // Instruct the world to perform a single step of simulation. It is
    // generally best to keep the time step and iterations fixed.
    model->world->Step(dt, velocityIterations, positionIterations);

    model->timeLeft_ -= dt;
    model->timeOfDay_ += dt;
    if (model->timeOfDay_ > daySeconds)
    {
        model->timeOfDay_ = 0.0f;
        [model randomizeWeather];
        
    }

}

- (void) update: (ccTime) dt
{
    
    timer_accumulator_ += dt;
    
    while ( timer_accumulator_ >= fixed_dt_ )
    {
        [self innerUpdate:fixed_dt_*model->gameSpeed_];
        timer_accumulator_ -= fixed_dt_;
    }

    {
        static ccTime achAccum = 0;
        achAccum += dt;
        if ((gameManager.isGameCenterEnabled == YES) && (achAccum > 0.5f))
        {
            [self checkAchievementsRealtime];
            achAccum = 0;
        }
    }
	
}

- (void) checkAchievementsRealtime
{
    
    GKAchievement *achievement = [gameManager getAchievementForIdentifier:@"com.kgtech.pickaSeaObject.achievement002"];
    if (achievement)
    {
        
        //achievement.percentComplete = percent;
        //[achievement reportAchievementWithCompletionHandler:^(NSError *error)
         //{
         //    if (error != nil)
         //    {
         //        // Log the error.
         //    }
         //}];
    
    
    
    if (gameManager->counters.fishCaught > 0)
    {
    //NSString* title = @"title";
    //NSString* message = achievement.description;
    //[GKNotificationBanner showBannerWithTitle: title message: message
     //                       completionHandler:^{
       //                         //[self advanceToNextInterfaceScreen]
         //                   }];
    }
    }
}

- (void)showConfirmAlert
{
    [self pauseGame];
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Confirm"];
	[alert setMessage:@"Are you sure you want to quit your game and go back to the main menu?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		//[[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0 scene:[MainMenuLayer scene]]];
    	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccWHITE]];
        [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
	}
	else if (buttonIndex == 1)
	{
        [self resumeGame];
	}
}

- (void) dealloc
{
    [self stopGame];
	[super dealloc];
	delete m_debugDraw;
	m_debugDraw = NULL;
    
}

- (void) cleanupTempLabels:(id) object
{
    NSLog(@"cleanup temp label");
    [self removeChild:object cleanup:YES];
}


- (void) startCatching: (CGPoint) location
{
    model->startCatchSeaObject = YES;
    model->catchSeaObjectCounter = model->catchSeaObjectTime;
    model->catchingTimer.position = location;
    id action = [CCFadeIn actionWithDuration:0.4f];
    [model->catchingTimer runAction:action];
    //show progress bar
}

- (void) stopCatching
{
    model->startCatchSeaObject = NO;
    model->currentSeaObjectBeingCaught = NULL;
    [model->catchingTimer stopAllActions];
    model->catchingTimer.opacity = 0;
}

- (void) didCatchObject:(b2Body *)objectBody
{
    PhysicsSprite* sp = (PhysicsSprite*)objectBody->GetUserData();
    //score calc
    if (sp.type == 0)
    {
        float f1 = (model->fishAliveTime-sp.timeAlive);
        uint64_t currentScore = 5*((model->difficulty+1)*1.5f)+f1*6.5;
        CCLabelBMFont* tempScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%llu",currentScore] fntFile:@"font-score-time.fnt"];
        tempScoreLabel.position = ccp(model->catchingTimer.position.x,model->catchingTimer.position.y);
        [self addChild:tempScoreLabel z:100];
        
        {
            id move = [CCMoveTo actionWithDuration:2 position:ccp(tempScoreLabel.position.x,winSize.height+tempScoreLabel.contentSize.height)];
            //id delay1 = [CCDelayTime actionWithDuration:2.0f];
            id fade = [CCFadeOut actionWithDuration:2.0f];
            id callcleanup = [CCCallFuncO actionWithTarget:self selector:@selector(cleanupTempLabels:) object:tempScoreLabel];
            id seqAction1 = [CCSequence actions:fade,callcleanup,nil];
            id spawn = [CCSpawn actions:move,seqAction1, nil];
            [tempScoreLabel runAction:spawn];
        }
        model->score += currentScore;
    
        ++(gameManager->counters.fishCaught);
        model->catchingTimer.opacity = 0;
        model->world->DestroyBody(model->currentSeaObjectBeingCaught);
        [model->seaObjectsParentNode removeChild:sp cleanup:YES];
        model->startCatchSeaObject = NO;
        model->currentSeaObjectBeingCaught = NULL;
        //play sound
    [   gameManager playSoundEffect:@"SPLASH1"];
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //int i = 0;
	//Add a new body/atlas sprite at the touched location
	for (UITouch* touch in touches)
    {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        //SeaObjectingRodSprite.position = ccp(SeaObjectingRodSprite.position.x-10,SeaObjectingRodSprite.position.y);
        //b2Vec2 p = b2Vec2(ptm(location.x),ptm(location.y));
        if ((model->currentSeaObjectBeingCaught = [self testCollision:location]) != NULL)
        {
            [self startCatching:location];
        }
        //SeaObjectingRod.rod->SetTransform(p,0);
        break;
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
        b2Vec2 p = b2Vec2(ptm(location.x),ptm(location.y));
        if (model->currentSeaObjectBeingCaught != NULL && model->startCatchSeaObject == YES)
        {
            if ( model->currentSeaObjectBeingCaught->GetFixtureList()->TestPoint(p))
            {
                //NSLog(@"careful you are moving");
                model->catchingTimer.position = location;
            }
            else
            {
                [self stopCatching];
                //no single SeaObject lost achievement
                NSLog(@"you lost the SeaObject!");
            }
        }
        //SeaObjectingRod.rod->SetTransform(p,0);
        
        //if ([self testCollision:location] == YES)
        {
            //startCatchSeaObject = YES;
            //catchSeaObjectCounter = catchSeaObjectTime;
            //show progress bar
        }
        
        break; //first touch only
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (model->catchSeaObjectCounter <= 0 && model->startCatchSeaObject == YES)
    {
        NSLog(@"Caught SeaObject 2");
    }
    [self stopCatching];
    
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];

	}
}



- (b2Body*) testCollision: (const CGPoint&) location
{
    b2Vec2 p = b2Vec2(ptm(location.x),ptm(location.y));
    b2AABB aabb;
    b2Vec2 d;
    d.Set(0.001f, 0.001f);
    aabb.lowerBound = p - d;
    aabb.upperBound = p + d;
    FishCollideCallback callback(p);
    model->world->QueryAABB(&callback, aabb);
    if ( callback.fixtureFound)
        return callback.fixtureFound->GetBody();
    else
        return NULL;
}
/*
- (BOOL) launchObject: (const CGPoint&) location
{
    b2Vec2 p = b2Vec2(ptm(location.x),ptm(location.y));
    
    // Make a small box.
    b2AABB aabb;
    b2Vec2 d;
    d.Set(0.001f, 0.001f);
    aabb.lowerBound = p - d;
    aabb.upperBound = p + d;
    
    // Query the world for overlapping shapes.
    SeaObjectCollideCallback callback(p);
    model->world->QueryAABB(&callback, aabb);
    
    if (callback.fixtureFound)
    {
        b2Body* body = callback.fixtureFound->GetBody();
        b2Vec2 force = b2Vec2(0,10000.0f);
        body->ApplyForceToCenter(force);
        //body->ApplyLinearImpulse(force,b2Vec2(0.5f,0.5f));
        /*b2MouseJointDef md;
         md.bodyA = m_groundBody;
         md.bodyB = body;
         md.target = p;
         #ifdef TARGET_FLOAT32_IS_FIXED
         md.maxForce = (body->GetMass() < 16.0)?
         (1000.0f * body->GetMass()) : float32(16000.0);
         #else
         md.maxForce = 1000.0f * body->GetMass();
         #endif
         m_mouseJoint = (b2MouseJoint*)m_world->CreateJoint(&md);*/
   /*     body->SetAwake(true);
        return YES;
    }
    return NO;
}*/


@end
