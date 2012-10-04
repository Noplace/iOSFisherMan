//
//  BackgroundLayer.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "BackgroundLayer.h"


uint8_t lerpu8(uint8_t a,uint8_t b,float t)
{
    return a+t*(b - a);
}

ccColor3B colorLerp3B(const ccColor3B& a, const ccColor3B& b,float t)
{
    ccColor3B res;
    res.r = a.r+t*(b.r - a.r);
    res.g = a.g+t*(b.g - a.g);
    res.b = a.b+t*(b.b - a.b);
    return res;
}

ccColor4F colorLerp4F(const ccColor4F& a, const ccColor4F& b,float t)
{
    ccColor4F res;
    res.r = a.r+t*(b.r - a.r);
    res.g = a.g+t*(b.g - a.g);
    res.b = a.b+t*(b.b - a.b);
    res.a = a.a+t*(b.a - a.a);
    return res;
}

@interface BackgroundLayer()
{
    CCSpriteBatchNode* cloudsParent;
    CCTexture2D* cloudsTexture;
    float cloudsIntensity;
    BOOL cloudsEnable;
    float cloudsOpacity;
    ccTime cloudTimer_;
    
    CCSprite* sunSprite;
    CCSprite* moonSprite;
    CCSprite* skyDaySprite;
    CCSprite* skyNightSprite;

    int skyPhase;
    float skyTime;
    float sunTime;
    float moonTime;
    
}
- (void) addCloud: (ccTime) dt location:(CGPoint) location;
- (void) updateSun: (ccTime) dt;
- (void) updateMoon: (ccTime) dt;
- (void) updateSky: (ccTime) dt;
- (void) updateClouds: (ccTime) dt;
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
        
        self.isTouchEnabled = YES;//NO
		self.isAccelerometerEnabled = NO;//NO
        skyPhase=3;
        skyTime = 0.0f;
        
        moonTime = 0;
        sunTime = 0;
       
        skyDaySprite = [CCSprite spriteWithFile:@"sky-day.png" rect:CGRectMake(0,0,size.width,size.height)];
        skyNightSprite = [CCSprite spriteWithFile:@"sky-night.png" rect:CGRectMake(0,0,size.width,size.height)];
        sunSprite = [CCSprite spriteWithFile:@"sun.png" rect:CGRectMake(0,0,128,128)];
        moonSprite = [CCSprite spriteWithFile:@"moon.png" rect:CGRectMake(0,0,128,128)];
 
    
        //sprite.position = ccp(0,0);
        //ccTexParams tp = {GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT};
        
        //[sprite.texture setTexParameters:&tp];
        skyDaySprite.opacity = 255;
        skyDaySprite.anchorPoint = ccp(0,0);
        skyNightSprite.opacity = 0;
        skyNightSprite.anchorPoint = ccp(0,0);
        
        
        cloudsParent = [CCSpriteBatchNode batchNodeWithFile:@"clouds.png" capacity:100];
		cloudsTexture = [cloudsParent texture];
        cloudsOpacity = 0;
    
        
       
        
        [self addChild:skyDaySprite z:-1];
        [self addChild:skyNightSprite z:-1];
        [self addChild:sunSprite z:0];
        [self addChild:moonSprite z:0];
        [self addChild:cloudsParent z:1];
        
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

- (void) resetCloudsTimer
{
    cloudTimer_ = CCRANDOM_0_1()*timeRatio*(1.0001f-cloudsIntensity);
}

- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity
{
    if (cond == kWeatherConditionClouds)
    {
        cloudsIntensity = intensity;
        cloudsEnable = enable;
        [self resetCloudsTimer];
    }
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


- (void) updateSun:(ccTime) dt
{
    float ampX=size.width/2;
    float ampY=size.height;
    
    sunSprite.opacity = 50+120*(sin(kmPI*sunTime*2));
    sunSprite.position = ccp(ampX-ampX*cos(2*kmPI*sunTime),ampY*sin(2*kmPI*sunTime));
    
    
}

- (void) updateMoon:(ccTime) dt
{
    float ampX=size.width/2;
    float ampY=size.height;
    float phase = 0;
    
    moonSprite.opacity = 50+120*(sin(kmPI*moonTime*2));
    moonSprite.position = ccp(ampX-ampX*cos(2*kmPI*moonTime+phase),ampY*sin(2*kmPI*moonTime+phase));
    
    
}

- (void) updateSky:(ccTime) dt 
{

    if (timeOfDay_ >= sunriseStart && timeOfDay_ <= (sunriseStart+sunriseDuration) && skyPhase == 3)
    {
        skyPhase = 0;//start sunrise
        skyTime = timeOfDay_-sunriseStart;
        sunTime = 0;
    }
    else if (timeOfDay_ >= sunsetStart && skyPhase == 0)
    {
        skyPhase = 3;//start sunset
        skyTime = timeOfDay_-sunsetStart;
        sunTime = 0.25f;
        moonTime = -0.25f;
    }
    
    if (skyPhase == 0 && skyTime <= sunriseDuration)
    {
        float t = skyTime/sunriseDuration;
        sunTime = t*0.25f;
        moonTime = 0.25f + t*0.5f;
        skyDaySprite.opacity = lerpu8(0,255,t);
        skyNightSprite.opacity = lerpu8(255,0,t);
    }
    else if (skyPhase == 3 && skyTime <= sunsetDuration)
    {
        float t = skyTime/sunsetDuration;
        sunTime = 0.25f + t*0.25f;
        moonTime = -0.25f + t*0.5f;
        skyDaySprite.opacity = lerpu8(255,0,t);
        skyNightSprite.opacity = lerpu8(0,255,t);
    }
    
    
    
    skyTime+=dt;
}




- (void) addCloud:(ccTime) dt location:(CGPoint) location
{
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
    PhysicsSprite* cloudSprite = [PhysicsSprite spriteWithTexture:cloudsTexture rect:CGRectMake(idx*128,idy*64,128,64)];
    [cloudsParent addChild: cloudSprite];
    
    
    float randY = (random() % (int)size.height) * 0.32f;
    cloudSprite.position = ccp(size.width+128,size.height-32-randY);
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_kinematicBody;
	bodyDef.position.Set(cloudSprite.position.x/PTM_RATIO,cloudSprite.position.y/PTM_RATIO);
	b2Body *body = world_->CreateBody(&bodyDef);
    b2Vec2 newVelocity = b2Vec2(-260.0f*dt/timeRatio,0);
    body->SetLinearVelocity( newVelocity );
    
	[cloudSprite setPhysicsBody:body];
}

- (void) updateClouds: (ccTime) dt
{
    cloudTimer_ -= dt;
    //if (random() % 10000 > 9900)
    if (cloudTimer_ <= 0.0f)
    {
        [self resetCloudsTimer];
        if (cloudsEnable)
            [self addCloud:dt location:CGPointMake(0,0)];
       
        
        for (int i=0;i<[cloudsParent.children count];++i)
        {
            PhysicsSprite* sp = [cloudsParent.children objectAtIndex:i];
            if (!sp)
                continue;
            b2Vec2 pos = sp->body_->GetPosition();
            if (pos.x < -(128/PTM_RATIO))
            {
                world_->DestroyBody(sp->body_);
                [cloudsParent removeChild:sp cleanup:YES];
                //NSLog(@"deleted cloud %d, total = %d",i,[cloudsParent.children count]);
            }
        }
    }
    
    

    if (cloudsEnable)
    {
        if (cloudsOpacity < 1.0f)
        {
            cloudsOpacity = MIN(cloudsOpacity+dt,1.0f);
            for(CCSprite* sprite in [cloudsParent children])
            {
                sprite.opacity = cloudsOpacity*255;
            }
        }
        else
            cloudsOpacity = 1.0f;
    }
    else
    {
        if (cloudsOpacity > 0.0f)
        {
            cloudsOpacity = MAX(cloudsOpacity-dt,0.0f);
            for(CCSprite* sprite in [cloudsParent children])
            {
                sprite.opacity = cloudsOpacity*255;
            }
        }
        else
            cloudsOpacity = 0.0f;
    }
}


- (void) update: (ccTime) dt
{
    [self updateSky:dt];
    [self updateSun:dt];
    [self updateMoon:dt];
    [self updateClouds:dt];
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
