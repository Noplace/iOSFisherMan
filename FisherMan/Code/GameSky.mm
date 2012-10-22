//
//  GameSky.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/9/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import "GameSky.h"


template<typename T1,typename T2>
union AnyCast
{
    T1 in;
    T2 out;
};

float bits2float(uint32_t u)
{
    AnyCast<uint32_t,float> x;
    x.in = u;
    return x.out;
}

inline uint32_t RandomInt(uint32_t* seed)
{
    *seed = *seed * 196314165 + 907633515;
    return *seed;
}

inline float RandomFloat(uint32_t* seed)
{
    uint32_t bits = RandomInt(seed);
    float f = bits2float((bits>>9)|0x40000000);
    return f - 3.0f;
}

inline float Noise(uint32_t* seed)
{
    float r1 = (1+RandomFloat(seed))*0.5f;
    float r2 = (1+RandomFloat(seed))*0.5f;
    return float(sqrt(-2.0f*log(r1))*(cos(2.0f*kmPI*r2)));
}


@interface GameSky()
{
    CCSprite* skySprite;
    CCSpriteBatchNode* skyStarsBatchNode;
    uint32_t randomSeed;
}
@end

@implementation GameSky

@synthesize model;

- (id) initWithModel:(GameModel*) gameModel;
{
    [super init];
    model = gameModel;
    [self initSky];
    return self;
}

- (void) randomizeStars
{
    for (CCSprite* sp in skyStarsBatchNode.children)
    {
        float xr = (1+RandomFloat(&randomSeed))*0.5f;
        float yr = (1+RandomFloat(&randomSeed))*0.5f;
        sp.position = ccp(xr*model->winSize.width,yr*model->winSize.height);
    }
    
}

- (void) initSky
{
    model->dayOfYear = 100;//[SolarUtil dayOfYear:[NSDate date]];
    randomSeed = 1;
    model->skyPhase=3;
    model->skyTime = 0.0f;
    
    model->moonTime = 0;
    model->sunTime = 0;
    
    
    skyStarsBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"particle-stars.png"];
    
    for (int i=0;i<12;++i)
    {
        CCSprite* starSprite = [CCSprite spriteWithTexture:skyStarsBatchNode.texture];
        //float xr = (1+RandomFloat(&randomSeed))*0.5f;
        //float yr = (1+RandomFloat(&randomSeed))*0.5f;
        //starSprite.position = ccp(xr*model->winSize.width,yr*model->winSize.height);
        starSprite.scale = 0.5f;
        [skyStarsBatchNode addChild:starSprite];
    }
    [model->bgLayer addChild:skyStarsBatchNode z:0];
    [self randomizeStars];

    skySprite = [CCSprite spriteWithFile:@"sky.png" rect:CGRectMake(0,0,model->winSize.width,model->winSize.height)];
    //model->skyDaySprite = [CCSprite spriteWithFile:@"sky-day.png" rect:CGRectMake(0,0,model->winSize.width,model->winSize.height)];
    //model->skyNightSprite = [CCSprite spriteWithFile:@"sky-night.png" rect:CGRectMake(0,0,model->winSize.width,model->winSize.height)];
    model->sunSprite = [CCSprite spriteWithFile:@"sun.png" ];
    model->moonSprite = [CCSprite spriteWithFile:@"moon.png" ];
    
    
    //sprite.position = ccp(0,0);
    //ccTexParams tp = {GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT};
    
    //[sprite.texture setTexParameters:&tp];
    //model->skyDaySprite.opacity = 255;
    //model->skyDaySprite.anchorPoint = ccp(0,0);
    //model->skyNightSprite.opacity = 0;
    //model->skyNightSprite.anchorPoint = ccp(0,0);
    
    skySprite.anchorPoint = ccp(0,0);
    
    model->cloudsParent = [CCSpriteBatchNode batchNodeWithFile:@"clouds.png" capacity:100];
    model->cloudsTexture = [model->cloudsParent texture];
    model->cloudsOpacity = 0;
    
    //[model->bgLayer addChild:model->skyDaySprite z:-1];
    //[model->bgLayer addChild:model->skyNightSprite z:-1];
    [model->bgLayer addChild:skySprite z:-1];
    [model->bgLayer addChild:model->sunSprite z:1];
    [model->bgLayer addChild:model->moonSprite z:1];
    [model->bgLayer addChild:model->cloudsParent z:2];
}



- (void) addCloud:(ccTime) dt location:(CGPoint) location
{
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
    PhysicsSprite* cloudSprite = [PhysicsSprite spriteWithTexture:model->cloudsTexture rect:CGRectMake(idx*128,idy*64,128,64)];
    [model->cloudsParent addChild: cloudSprite];
    
    
    float randY = (random() % (int)model->winSize.height) * 0.32f;
    cloudSprite.position = ccp(model->winSize.width+128,model->winSize.height-32-randY);
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_kinematicBody;
	bodyDef.position.Set(cloudSprite.position.x/PTM_RATIO,cloudSprite.position.y/PTM_RATIO);
	b2Body *body = model->world->CreateBody(&bodyDef);
    b2Vec2 newVelocity = b2Vec2(-260.0f*dt/timeRatio,0);
    body->SetLinearVelocity( newVelocity );
    
	[cloudSprite setPhysicsBody:body];
}


- (void) updateSun:(ccTime) dt
{
    float ampX=model->winSize.width/2;
    float ampY=model->winSize.height;
    
    model->sunSprite.opacity = 50+120*(sin(kmPI*model->sunTime*2));
    model->sunSprite.position = ccp(ampX-ampX*cos(2*kmPI*model->sunTime),ampY*sin(2*kmPI*model->sunTime));
    
    
    //CGPoint p = [SolarUtil sunPosition:dayOfYear year:2012 hour:timeOfDay_/timeRatio lat:37.75f lng:122.5f];
    
    //sunSprite.opacity = 50+120*(sin(kmPI*sunTime*2));
    //sunSprite.position = ccp(ampX-ampX*cos(p.x)-ampX,ampY*0.5+ampY*sin(p.y)-(sunSprite.contentSize.height*0.5f));
    
    
}

- (void) updateMoon:(ccTime) dt
{
    float ampX=model->winSize.width/2;
    float ampY=model->winSize.height;
    float phase = 0;
    
    model->moonSprite.opacity = 50+120*(sin(kmPI*model->moonTime*2));
    model->moonSprite.position = ccp(ampX-ampX*cos(2*kmPI*model->moonTime+phase),ampY*sin(2*kmPI*model->moonTime+phase));
    
    
}

- (void) updateSky:(ccTime) dt
{
    
    if (model->timeOfDay_ >= sunriseStart && model->timeOfDay_ <= (sunriseStart+sunriseDuration) && model->skyPhase == 3)
    {
        model->skyPhase = 0;//start sunrise
        model->skyTime = model->timeOfDay_-sunriseStart;
        model->sunTime = 0;
    }
    else if (model->timeOfDay_ >= sunsetStart && model->skyPhase == 0)
    {
        [self randomizeStars];
        model->skyPhase = 3;//start sunset
        model->skyTime = model->timeOfDay_-sunsetStart;
        model->sunTime = 0.25f;
        model->moonTime = -0.25f;
    }
    
    if (model->skyPhase == 0 && model->skyTime <= sunriseDuration)
    {
        float t = model->skyTime/sunriseDuration;
        model->sunTime = t*0.25f;
        model->moonTime = 0.25f + t*0.5f;
        skySprite.color = colorLerp3B(ccc3(50,50,50),ccc3(255,255,255),t);
        for (CCSprite* sp in skyStarsBatchNode.children)
        {
            sp.opacity = (1-t)*255;
        }
        //model->skyDaySprite.opacity = lerpu8(0,255,t);
        //model->skyNightSprite.opacity = lerpu8(255,0,t);
    }
    else if (model->skyPhase == 3 && model->skyTime <= sunsetDuration)
    {
        float t = model->skyTime/sunsetDuration;
        model->sunTime = 0.25f + t*0.25f;
        model->moonTime = -0.25f + t*0.5f;
        skySprite.color = colorLerp3B(ccc3(255,255,255),ccc3(50,50,50),t);
        
        for (CCSprite* sp in skyStarsBatchNode.children)
        {
            sp.opacity = (t)*255;
        }
        //model->skyDaySprite.opacity = lerpu8(255,0,t);
        //model->skyNightSprite.opacity = lerpu8(0,255,t);
    }
    
    
    
    model->skyTime+=dt;
}

- (void) updateClouds: (ccTime) dt
{
    model->cloudTimer_ -= dt;
    //if (random() % 10000 > 9900)
    if (model->cloudTimer_ <= 0.0f)
    {
        [model resetCloudsTimer];
        if (model->cloudsEnable)
            [self addCloud:dt location:CGPointMake(0,0)];
        
        
        for (int i=0;i<[model->cloudsParent.children count];++i)
        {
            PhysicsSprite* sp = [model->cloudsParent.children objectAtIndex:i];
            if (!sp)
                continue;
            b2Vec2 pos = sp->body_->GetPosition();
            if (pos.x < -(128/PTM_RATIO))
            {
                model->world->DestroyBody(sp->body_);
                [model->cloudsParent removeChild:sp cleanup:YES];
                //NSLog(@"deleted cloud %d, total = %d",i,[cloudsParent.children count]);
            }
        }
    }
    
    
    for(CCSprite* sprite in [model->cloudsParent children])
    {
        sprite.opacity = model->cloudsOpacity*255;
    }
}

- (void) update: (ccTime) dt
{
    [self updateSky:dt];
    [self updateSun:dt];
    [self updateMoon:dt];
    [self updateClouds:dt];
}

@end
