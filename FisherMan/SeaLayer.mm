//
//  HelloWorldLayer.mm
//  FisherMan
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

enum {
	kTagParentNode = 1,
    kTagSeaParentNode = 2
};

#define BUOYANCYOFFSET 140.0f
#define BOXNUMBERS 2
#pragma mark - SeaLayer


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
    b2BuoyancyController* seaBC;
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
	
		seaObjectsParentNode = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
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
                ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_MIRRORED_REPEAT, GL_CLAMP_TO_EDGE};
                
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

	}
	return self;
}


-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	

}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	//CCNode *parent = [self getChildByTag:kTagParentNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];						
	[seaObjectsParentNode addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	sprite.zOrder = -3;
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world_->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
    body->SetUserData(sprite);
	body->CreateFixture(&fixtureDef);
    
	
    seaBC->AddBody(body);
	[sprite setPhysicsBody:body];
}


-(void) updateSea:(ccTime) dt
{
    static const CGFloat pos[4]={30,50,60,80};
    static const CGFloat amp[4] = {10,12,20,26};
    static const CGFloat dir[4] = {-1,1,-1,1};
    static const CGFloat freq[4] = {1.3f,1.5f,0.8f,0.5f};
    static const CGFloat phase[4] = {kmPI*0.25f,0,kmPI,0};
    const float freqY = 0.2f;
    float dispX = (size.width*2.0f)/4;
    float rangeX = dispX/2;
    
    static float lastx[4] = {0,0,0,0};
    float dx=0;
    
    for (int i=0;i<4;++i)
    {
        lastx[i] = seaSprite[i].position.x;
        seaSprite[i].position = ccp(dispX+dir[i]*(sin((2*kmPI*waveTime_[i]*freq[i])+phase[i])*rangeX),pos[i]+sin(2*kmPI*waveYTime_*freqY)*amp[i]);
        dx += seaSprite[i].position.x - lastx[i];
        waveTime_[i] += dt*0.2f;
        waveYTime_ += dt*0.2f;
        if (waveTime_[i] >= (1/freq[i]))
        {
            waveTime_[i] -= (1/freq[i]);
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

    [self updateSea:dt];
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
        
        
        if ([self launchObject:location] == NO)
            [self addNewSpriteAtPosition: location];
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
