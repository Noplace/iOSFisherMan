//
//  GameLayer.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/26/2012.
//
//

#import "cocos2d.h"
#import "Box2D/Box2D.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"
#import "time.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


#define SCREENWIDTH (IS_IPAD ? 768.0 : 320.0)
#define SCREENHEIGHT (IS_IPAD ? 1024.0 : 480.0)


#define DEVSCALE(n) (IS_IPAD ? n*2 : n)

#define dccp(x,y) ccp(DEVSCALE(x),DEVSCALE(y))

#define BUOYANCYOFFSET 140.0f


enum WeatherCondition {
	kWeatherConditionClouds,
    kWeatherConditionRain,
    kWeatherConditionWind,
};

enum Tags
{
    kTagParentNode = 1,
    kTagSeaParentNode = 2,
    //kTagSeaFish,
    kTagSeaObject,
};

enum GameObjects
{
    kObjectTypeFish1 = 0,
    kObjectTypeSpecial
};



const float timeRatio = 0.4f;
const float daySeconds = 24.0f*timeRatio;
const float phaseSeconds = daySeconds/4.0f;

const float sunriseStart = 5.0f*timeRatio;
const float sunriseDuration = 6.0f*timeRatio;
const float sunsetStart = 17.0f*timeRatio;
const float sunsetDuration = 2.0f*timeRatio;

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

static inline float ptm(float d)
{
    return d / PTM_RATIO;
}

/** Convert the given position into the cocos2d world. */
static inline float mtp(float d)
{
    return d * PTM_RATIO;
}


static inline uint8_t lerpu8(uint8_t a,uint8_t b,float t)
{
    return a+t*(b - a);
}

static inline ccColor3B colorLerp3B(const ccColor3B& a, const ccColor3B& b,float t)
{
    ccColor3B res;
    res.r = a.r+t*(b.r - a.r);
    res.g = a.g+t*(b.g - a.g);
    res.b = a.b+t*(b.b - a.b);
    return res;
}

static inline ccColor4F colorLerp4F(const ccColor4F& a, const ccColor4F& b,float t)
{
    ccColor4F res;
    res.r = a.r+t*(b.r - a.r);
    res.g = a.g+t*(b.g - a.g);
    res.b = a.b+t*(b.b - a.b);
    res.a = a.a+t*(b.a - a.a);
    return res;
}

@protocol GameLayerProtocol <NSObject>

+ (id) nodeWithWorld: (b2World*) world;

@end


@protocol SeaObjectEventsReceiever <NSObject>

- (void) bombExplode: (b2Body*) objectBody;
- (void) didCatchObject: (b2Body*) objectBody;
- (void) stopCatching;
@end