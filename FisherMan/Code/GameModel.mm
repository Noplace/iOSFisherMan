//
//  GameModel.cpp
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/9/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#include "GameModel.h"

@implementation GameModel

- (id) init
{
	if( (self=[super init]))
    {
        winSize = [CCDirector sharedDirector].winSize;
        gameSpeed_ = 1.0f;
        level = 0;
        difficulty = 0;
        windIntensity = 0.0f;
        bgLayer = [CCLayer node];
        seaLayer = [CCLayer node];
        [self initPhysics];
        [self initRain];

        
        //[self scheduleUpdate];
        return self;
    }
    return nil;
}

- (void) dealloc
{
    [super dealloc];
    delete world;
	world = NULL;
}


- (void) initRain
{
    rainEmitter = [CCParticleRain node];
    
    [bgLayer addChild: rainEmitter z:10];
    
    CGPoint p = rainEmitter.position;
    
    rainEmitter.position = ccp( p.x, p.y);
    rainEmitter.angle = -90;
    rainEmitter.life = 7;
    rainEmitter.emissionRate = 20;
    rainEmitter.speed = 200;
    rainEmitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"Raindrop.png"];
    rainEmitter.startSize = 10.0f;
    [rainEmitter stopSystem];
    //[rainEmitter pauseSchedulerAndActions];
}

-(void) initPhysics
{
    
	timeOfDay_ = sunriseStart+3*timeRatio;
	
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity,true);
	
	
	// Do we want to let bodies sleep?
	//world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	

	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0,0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
    
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// bottom
	
	groundBox.Set(b2Vec2(0,ptm(-winSize.height)), b2Vec2(ptm(winSize.width),ptm(-winSize.height)));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	//groundBox.Set(b2Vec2(0,winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,winSize.height/PTM_RATIO));
	//groundBody->CreateFixture(&groundBox,0);
	
	// left
	//groundBox.Set(b2Vec2(0,winSize.height/PTM_RATIO), b2Vec2(0,0));
	//groundBody->CreateFixture(&groundBox,0);
	
	// right
	//groundBox.Set(b2Vec2(winSize.width/PTM_RATIO,winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,0));
	//groundBody->CreateFixture(&groundBox,0);
}


- (void) resetCloudsTimer
{
    cloudTimer_ = CCRANDOM_0_1()*timeRatio*(1.2001f-cloudsIntensity);
}

- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity
{
    if (cond == kWeatherConditionRain)
    {
        rainEmitter.emissionRate = intensity * 80.0f;
        rainEmitter.speed = intensity * 100;
        if (enable == YES)
            [rainEmitter resetSystem];
        else
            [rainEmitter stopSystem];
    }
    if (cond == kWeatherConditionWind)
    {
        //CCCallFuncND* myAction = [CCCallFuncND actionWithTarget:self selector:@selector(myMethod:data:) data:(void*)123];
        //CCFiniteTimeAction c;
        float oldValue = MAX(windIntensity,0.01f);
        //windIntensity = intensity*2;
        //should replace with dt value
        id modifyWind = [CCActionTween actionWithDuration:120*(1/60.0f) key:@"windIntensity" from:oldValue to:intensity];
        [self runAction:modifyWind];
    }
    if (cond == kWeatherConditionClouds && cloudsEnable != enable)
    {
        cloudsIntensity = intensity;
        cloudsEnable = enable;
        id ca = [CCActionTween actionWithDuration:120*(1/60.0f) key:@"cloudsOpacity" from:(float)!cloudsEnable to:(float)(cloudsEnable)];
        [self runAction:ca];
        [self resetCloudsTimer];
    }
}

- (void) randomizeWeather
{
    float intensity[3] = {CCRANDOM_0_1(),CCRANDOM_0_1(),CCRANDOM_0_1()*1.7f};
    BOOL enabled[3] = {CCRANDOM_0_1() > 0.5f?YES:NO,CCRANDOM_0_1() > 0.5f?YES:NO,CCRANDOM_0_1() > 0.5f?YES:NO};
    
    [self setWeatherCondition:kWeatherConditionClouds Enable:enabled[0] Intensity:intensity[0]];
    [self setWeatherCondition:kWeatherConditionRain Enable:enabled[1] Intensity:intensity[1]];
    [self setWeatherCondition:kWeatherConditionWind Enable:enabled[2] Intensity:intensity[2]];
}

- (void) destroyCaughtAndResetTimer
{
    catchingTimer.opacity = 0;
    world->DestroyBody(currentSeaObjectBeingCaught);
    [seaObjectsParentNode removeChild:(CCSprite*)currentSeaObjectBeingCaught->GetUserData() cleanup:YES];
    startCatchSeaObject = NO;
    currentSeaObjectBeingCaught = NULL;
}

- (void) draw
{
    //disabled drawing
}

@end