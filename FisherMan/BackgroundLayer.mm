//
//  BackgroundLayer.m
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "BackgroundLayer.h"

ccColor4F colorLerp(const ccColor4F& a, const ccColor4F& b,float t)
{
    ccColor4F res;
    res.r = a.r+t*(b.r - a.r);
    res.g = a.g+t*(b.g - a.g);
    res.b = a.b+t*(b.b - a.b);
    res.a = a.a+t*(b.a - a.a);
    return res;
}

@implementation BackgroundLayer

-(id) init
{
	if( (self=[super init])) {
        size = [CCDirector sharedDirector].winSize;
		//CCSprite* sprite = [[CCSprite alloc] init];
        //sprite.color = ccc3(255,255,255);
        t=0;
        //sprite.position = ccp(0,0);
        //[self addChild:sprite];
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}


-(void) draw
{
    
	[super draw];
    
    //glEnable(GL_LINE_SMOOTH);
    
    //glColor4ub(255, 0, 255, 255);
    //glLineWidth(2);
    //CGPoint vertices2[] = { ccp(79,299), ccp(134,299), ccp(134,229), ccp(79,229) };
    //ccDrawPoly(vertices2, 4, YES);
        ccDrawSolidRect(ccp(0,0),ccp(size.width,size.height),skyColor);
    
}
-(void) update: (ccTime) dt
{
    const ccTime fixed_dt_ = 1.0f/60.0f;
    
    ccColor4F color1 = ccc4f(1.0f, 1.0f, 1.0f, 1.0f);
    ccColor4F color2 = ccc4f(1.0f, 0.0f, 1.0f, 1.0f);
    skyColor = colorLerp(color1,color2,t);

    
    t+=0.01f*dt;
    t = fmod(t,1.0f);
	
}


@end
