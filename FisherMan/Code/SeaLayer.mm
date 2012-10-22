//
//  HelloWorldLayer.mm
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "SeaLayer.h"


// Needed to obtain the Navigation Controller
//#import "AppDelegate.h"

//#import "PhysicsSprite.h"
//#import "SeaWaveSprite.h"




@interface SeaLayer()


@end

@implementation SeaLayer

+ (id) nodeWithWorld: (b2World*) world
{
    SeaLayer* obj = [SeaLayer alloc];
    obj->world_ = world;
    return [[obj init] autorelease];
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		//self.isTouchEnabled = YES;
		//self.isAccelerometerEnabled = YES;
		//size = [CCDirector sharedDirector].winSize;
		
		
	}
	return self;
}

- (void) dealloc
{
    [super dealloc];
    //world_->DestroyJoint(fishingRod.ropeJoint);
    //world_->DestroyBody(fishingRod.rod);
    //world_->DestroyBody(fishingRod.hook);
}

-(void) draw
{
	[super draw];
    //[fishingRod.rope debugDraw:nil];
}

-(void) myMethod:(CCNode*)node data:(int)number {
    CCLOG(@"Was called with node %@ and number %i", node, number);
}

- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity
{

}

- (void) update: (ccTime) dt
{

 

	
}


@end
