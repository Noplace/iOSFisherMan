//
//  Header.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/9/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#ifndef Pick_a_Fish_GameModel_h
#define Pick_a_Fish_GameModel_h


//#import "VRope.h"
//#import "SolarUtil.h"
#import "GameUtil.h"
//#import "SeaHelper.h"

//it inherits CCNode to support runAction
@interface GameModel : CCNode
{

@public    CGSize winSize;
@public    CCLayer *bgLayer;
@public    CCLayer *seaLayer;
@public    CCParticleSystem* rainEmitter;
@public    CCProgressTimer* catchingTimer;
@public    CCTexture2D *seaObjectsTexture;
@public    CCTexture2D* cloudsTexture;
@public    CCTexture2D* seaShallowTexture;
@public    CCTexture2D *seaDeepTexture;
@public   CCSpriteBatchNode* cloudsParent;
@public   CCSpriteBatchNode *seaObjectsParentNode;
//@public   CCSpriteBatchNode* seaParentNode;
@public   CCSprite* seaSprite[4];
@public   CCSprite* sunSprite;
@public   CCSprite* moonSprite;
//@public   CCSprite* skyDaySprite;
//@public   CCSprite* skyNightSprite;
@public   b2World* world;
@public   b2BuoyancyController* seaBC;
@public   b2Body* currentSeaObjectBeingCaught;
    
@public    ccTime timeOfDay_;
@public    ccTime seaObjectSpawnCounter;
@public    ccTime fishAliveTime;
@public    ccTime specialsAliveTime;
@public    ccTime seaObjectSpawnTime;
@public    ccTime cloudTimer_;
@public    ccTime catchSeaObjectCounter,catchSeaObjectTime;
    
@public    float gameSpeed_;
@public    float timeLeft_;
@public    float windIntensity;
@public    float waveTime_[4];
@public    float waveYTime_;
@public    float cloudsIntensity;
@public    float cloudsOpacity;
@public    float skyTime;
@public    float sunTime;
@public    float moonTime;
@public    NSUInteger dayOfYear;
@public    int skyPhase;
@public    BOOL startCatchSeaObject;
@public    BOOL cloudsEnable;
 
@public     int level;
@public     int difficulty;
@public     int64_t score;

}

- (void) resetCloudsTimer;
- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity;
- (void) randomizeWeather;
@end

#endif
