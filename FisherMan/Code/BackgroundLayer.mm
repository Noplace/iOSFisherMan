//
//  BackgroundLayer.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "BackgroundLayer.h"
#import "SolarUtil.h"



@interface BackgroundLayer()
{

    
}

@end


@implementation BackgroundLayer

+ (id) nodeWithWorld: (b2World*) world
{
    BackgroundLayer* obj = [BackgroundLayer alloc];
    obj->world_ = world;
    return [[obj init] autorelease];
}

-(id) init
{
	if( (self=[super init])) {
        size = [CCDirector sharedDirector].winSize;
        //self.isTouchEnabled = YES;//NO
        //self.isAccelerometerEnabled = NO;//NO
        
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity
{
 
}


-(void) draw
{
    //grad.color = skyColor;
	[super draw];
    //[sprite draw];
    //glEnable(GL_LINE_SMOOTH);
    
    //glColor4ub(255, 0, 255, 255);
    //glLineWidth(2);
    //CGPoint vertices2[] = { ccp(79,299), ccp(134,299), ccp(134,229), ccp(79,229) };
    //ccDrawPoly(vertices2, 4, YES);
    //ccDrawSolidRect(ccp(0,0),ccp(size.width,size.height),skyColor);
    
}



- (void) update: (ccTime) dt
{

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		//CGPoint location = [touch locationInView: [touch view]];
		
		//location = [[CCDirector sharedDirector] convertToGL: location];
		//[self setWeatherCondition:kWeatherConditionRain Enable:NO Intensity:1.0f];
		//[self addCloud:0 location:location];
	}
}


@end
