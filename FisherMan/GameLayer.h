//
//  GameLayer.h
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/26/2012.
//
//

#import "cocos2d.h"
#import "Box2D/Box2D.h"
#import "GLES-Render.h"
#import "PhysicsSprite.h"

const float daySeconds = 24.0f;
const float phaseSeconds = daySeconds/4.0f;

const float sunriseStart = 5.0f;
const float sunriseDuration = 6.0f;
const float sunsetStart = 17.0f;
const float sunsetDuration = 2.0f;

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


@protocol GameLayerProtocol <NSObject>

+ (id) nodeWithWorld: (b2World*) world;

@end

@interface GameLayer : CCLayer <GameLayerProtocol>
{
    CGSize size;
    ccTime timeOfDay_;
    b2World* world_;
}
@property ccTime timeOfDay;
@end
