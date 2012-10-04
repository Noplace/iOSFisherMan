//
//  HelloWorldLayer.mm
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "SeaLayer.h"
#import "VRope.h"

// Needed to obtain the Navigation Controller
//#import "AppDelegate.h"

//#import "PhysicsSprite.h"
//#import "SeaWaveSprite.h"

enum {
	kTagParentNode = 1,
    kTagSeaParentNode = 2,
    kTagSeaFish,
    kTagSeaObject,
};

#define BUOYANCYOFFSET 140.0f


class SimpleQueryCallback : public b2QueryCallback
{
public:
    b2Vec2 pointToTest;
    b2Fixture * fixtureFound;
    SimpleQueryCallback(const b2Vec2& point) {
        pointToTest = point;
        fixtureFound = NULL;
    }
    bool ReportFixture(b2Fixture* fixture) {
        b2Body* body = fixture->GetBody();
        if (body->GetType() == b2_dynamicBody) {
            if (fixture->TestPoint(pointToTest)) {
                fixtureFound = fixture;
                return false;
            } }
        return true;
    }
};


@interface SeaLayer()
{
	CCTexture2D *spriteTexture_;	// weak ref
    CCSpriteBatchNode *seaObjectsParentNode;
    CCSpriteBatchNode* seaParentNode;
    CCSprite* seaSprite[4];
    float windIntensity;
    b2BuoyancyController* seaBC;
    
    
    struct {
        b2Body* rod,*hook;
        PhysicsSprite *rodSprite;
        PhysicsSprite *hookSprite;
        b2RopeJoint* ropeJoint;
        VRope* rope;
        CCSpriteBatchNode* ropeNode;
    }fishingRod;
    float waveTime_[4];
    float waveYTime_;
}
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) updateSea:(ccTime) dt;
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
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		size = [CCDirector sharedDirector].winSize;
		
		// init physics

        memset(waveTime_,0,sizeof(waveTime_));
        waveYTime_ = 0;
        
        // Define the buoyancy controller
        b2BuoyancyControllerDef bcd;
        
        bcd.normal.Set(0.0f, 1.0f);
        bcd.offset = ptm(40);
        bcd.density = 2.0f;
        bcd.linearDrag = 7.0f;
        bcd.angularDrag = 10.0f;
        bcd.useWorldGravity = true;
        
        seaBC = (b2BuoyancyController *)world_->CreateController(&bcd);
	
		seaObjectsParentNode = [CCSpriteBatchNode batchNodeWithFile:@"fish1.png" capacity:100];
		spriteTexture_ = [seaObjectsParentNode texture];

		[self addChild:seaObjectsParentNode z:-3 tag:kTagParentNode];
	
        
        {
            seaParentNode = [CCSpriteBatchNode batchNodeWithFile:@"sea_wave.png" capacity:100];
            CCTexture2D* seaTexture = [seaParentNode texture];
            static ccColor3B seaColors[4] = {
                ccc3(0, 82, 240),
                ccc3(0, 62, 200),
                ccc3(0, 42, 160),
                ccc3(0, 22, 140)
            };
            for (int i=0;i<4;++i)
            {
                seaSprite[i] = [CCSprite spriteWithTexture:seaTexture rect:CGRectMake(0,0,size.width*2.0f,128)];
                ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
                
                [seaSprite[i].texture setTexParameters:&tp];
                seaSprite[i].color = seaColors[i];
                seaSprite[i].opacity = 225-(i*10);
                //seaSprite.
                //sprite.anchorPoint = ccp(0,0);
                seaSprite[i].zOrder = -(i<<1);
                seaSprite[i].position = ccp(0,0);
                [self addChild:seaSprite[i]];
            }
        }

        
        [self createFishingRod];
	}
	return self;
}

- (void) dealloc
{
    [super dealloc];
    world_->DestroyJoint(fishingRod.ropeJoint);
    world_->DestroyBody(fishingRod.rod);
    world_->DestroyBody(fishingRod.hook);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
    //[fishingRod.rope debugDraw:nil];

}

-(void) myMethod:(CCNode*)node data:(int)number {
    CCLOG(@"Was called with node %@ and number %i", node, number);
}

- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity
{
    if (cond == kWeatherConditionWind)
    {
        //CCCallFuncND* myAction = [CCCallFuncND actionWithTarget:self selector:@selector(myMethod:data:) data:(void*)123];
        //CCFiniteTimeAction c;
        windIntensity = intensity*2;
        
        
    }
}


-(void) createFishingRod
{
    CGPoint rodPoint = ccp(size.width/2.0f,size.height/2.0f);
	CGPoint hookPoint = rodPoint;
    hookPoint.y -= 100;
	
    //rod
    fishingRod.rodSprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(0,0,32,32)];
	[seaObjectsParentNode addChild:fishingRod.rodSprite];
    fishingRod.rodSprite.position = rodPoint;
    fishingRod.hookSprite.zOrder =  -3;
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(rodPoint.x/PTM_RATIO,rodPoint.y/PTM_RATIO);
	fishingRod.rod = world_->CreateBody(&bodyDef);
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(ptm(32)*0.5f, ptm(32)*0.5f);//These are mid points for our 1m box
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 10.0f;
	fixtureDef.friction = 1.3f;
    fishingRod.rod->SetUserData(fishingRod.rodSprite);
	fishingRod.rod->CreateFixture(&fixtureDef);
    
    //hook
	fishingRod.hookSprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(0,0,32,32)];
	[seaObjectsParentNode addChild:fishingRod.hookSprite];
    fishingRod.hookSprite.position = hookPoint;
	fishingRod.rodSprite.zOrder = -3;
    
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(hookPoint.x/PTM_RATIO,hookPoint.y/PTM_RATIO);
	fishingRod.hook = world_->CreateBody(&bodyDef);
    seaBC->AddBody(fishingRod.hook);
    dynamicBox.SetAsBox(ptm(32)*0.5f, ptm(32)*0.5f);//These are mid points for our 1m box
	
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 10.0f;
	fixtureDef.friction = 1.3f;
    fishingRod.hook->SetUserData(fishingRod.hookSprite);
	fishingRod.hook->CreateFixture(&fixtureDef);
    
    
    b2RopeJointDef rjdef;
    rjdef.bodyA = fishingRod.rod;
    rjdef.bodyB = fishingRod.hook;
    rjdef.collideConnected = false;
    rjdef.localAnchorA = b2Vec2(0.5f,0.5f);
    rjdef.localAnchorB = b2Vec2(0.5f,0.5f);
    rjdef.maxLength = ptm(100);
	fishingRod.ropeJoint = (b2RopeJoint*)world_->CreateJoint(&rjdef);
    
    fishingRod.ropeNode = [CCSpriteBatchNode batchNodeWithFile:@"rope.png" capacity:100];
    [self addChild:fishingRod.ropeNode];
    fishingRod.rope = [[VRope alloc] init:fishingRod.ropeJoint batchNode:fishingRod.ropeNode];
    [fishingRod.rope reset];
    
    //seaBC->AddBody(body1);
    //seaBC->AddBody(body2);
	[fishingRod.rodSprite setPhysicsBody:fishingRod.rod];
    [fishingRod.hookSprite setPhysicsBody:fishingRod.hook];
}


-(void) addNewFish
{
	CCLOG(@"Add fish");
	
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(0,0,48,86)];
	[seaObjectsParentNode addChild:sprite z:-3 tag:kTagSeaFish];
	
    CGPoint p;
    p.x = CCRANDOM_0_1() * (size.width-48);
    p.y = -100.0f;
	sprite.position = ccp(p.x,p.y);
	//sprite.zOrder = -3;
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world_->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(ptm(48)*0.5f, ptm(86)*0.5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
    body->SetUserData(sprite);
	body->CreateFixture(&fixtureDef);
    b2Vec2 force = b2Vec2(0,4900.0f);
    body->ApplyForceToCenter(force);
	
    seaBC->AddBody(body);
    sprite.timeAlive = 0;
	[sprite setPhysicsBody:body];
}


-(void) updateSea:(ccTime) dt
{
    static const CGFloat pos[4]={30,50,60,80};
    static const CGFloat amp[4] = {10,12,20,26};
    static const CGFloat dir[4] = {-1,1,-1,1};
    static const CGFloat freq[4] = {1.3f,1.5f,0.8f,0.5f};
    static const CGFloat phase[4] = {kmPI*0.25f,0,kmPI,0};
    const float freqY = 0.2f*windIntensity;
    float dispX = windIntensity*0.5f*(size.width*2.0f)/4;
    float rangeX = dispX/2;
    
    static float lastx[4] = {0,0,0,0};
    float dx=0;
    
    for (int i=0;i<4;++i)
    {
        float freqX = freq[i]*windIntensity;
        lastx[i] = seaSprite[i].position.x;
        seaSprite[i].position = ccp(dispX+dir[i]*(sin((2*kmPI*waveTime_[i]*freqX)+phase[i])*rangeX),pos[i]+sin(2*kmPI*waveYTime_*freqY)*amp[i]);
        dx += seaSprite[i].position.x - lastx[i];
        waveTime_[i] += dt*0.2f;
        waveYTime_ += dt*0.2f;
        if (waveTime_[i] >= (1/freqX))
        {
            waveTime_[i] -= (1/freqX);
        }
        if (waveYTime_ >= (1/freqY) )
            waveYTime_ -= (1/freqY);
    }
    
    seaBC->offset = ptm(seaSprite[2].position.y);
    dx = seaSprite[2].position.x - lastx[2];
    b2Vec2 force = b2Vec2(dx*100/rangeX,0);
    
    b2Body* body = world_->GetBodyList();
    
    while (body != NULL)
    {
        body->ApplyForceToCenter(force);
        body = body->GetNext();
    }
    
    
}

- (void) update: (ccTime) dt
{

    //rope
    [fishingRod.rope update:dt];
    [fishingRod.rope updateSprites];
    
    
    [self updateSea:dt];
    
    //fish
    for (int i=0;i<[seaObjectsParentNode.children count];++i)
    {
        PhysicsSprite* sp = [seaObjectsParentNode.children objectAtIndex:i];
        if (sp.tag == kTagSeaFish)
        {
            sp.timeAlive += dt;
            if (sp.timeAlive >= 5.0f)
                sp->body_->ApplyForceToCenter(b2Vec2(0,-500.0f));
            
            if (sp.timeAlive > 5.0f+5.0f)
            {
                world_->DestroyBody(sp->body_);
                [seaObjectsParentNode removeChild:sp cleanup:YES];
            }
        }
        
    }
	
}




- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
        //fishingRodSprite.position = ccp(fishingRodSprite.position.x-10,fishingRodSprite.position.y);
        b2Vec2 p = b2Vec2(ptm(location.x),ptm(location.y));
        
        fishingRod.rod->SetTransform(p,0);
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
        b2Vec2 p = b2Vec2(ptm(location.x),ptm(location.y));
        
        fishingRod.rod->SetTransform(p,0);
      
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
        
        
        //if ([self launchObject:location] == NO)
        //    [self addNewFish];
	}
}

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
        SimpleQueryCallback callback(p);
        world_->QueryAABB(&callback, aabb);
    
        if (callback.fixtureFound)
        {
            b2Body* body = callback.fixtureFound->GetBody();
            b2Vec2 force = b2Vec2(0,1000.0f);
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
            body->SetAwake(true);
            return YES;
        }
    return NO;
}


@end
