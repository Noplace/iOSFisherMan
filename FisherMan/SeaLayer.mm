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
#import "AppDelegate.h"

#import "PhysicsSprite.h"
#import "SeaWaveSprite.h"

enum {
	kTagParentNode = 1,
    kTagSeaParentNode = 2
};


#pragma mark - SeaLayer

@interface SeaLayer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) updateSea:(ccTime) dt;
@end

@implementation SeaLayer

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		size = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
	
		
		//Set up sprite
		
#if 1
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:-3 tag:kTagParentNode];
	
        parentNode = [self getChildByTag:kTagParentNode];
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
            //[self addChild:seaParentNode z:0 tag:kTagSeaParentNode];
            //[seaParentNode release];
        }
        
		
	
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}	

-(void) initPhysics
{
    accumulator_ = 0;
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	//kmGLPushMatrix();
	
	//world->DrawDebugData();
	
	//kmGLPopMatrix();
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
	[parentNode addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	sprite.zOrder = -3;
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:body];
}


-(void) updateSea:(ccTime) dt
{
    static float time = 0;
    static CGFloat pos[4]={30,50,60,80};
    static CGFloat amp[4] = {10,12,20,26};
    static CGFloat dir[4] = {-1,1,-1,1};
    static CGFloat freq[4] = {1.3f,1.5f,0.8f,0.5};
    static CGFloat phase[4] = {kmPI*0.25f,0,kmPI,0};
    
    float dispX = (size.width*2.0f)/4;
    float rangeX = dispX/2;
    
    for (int i=0;i<4;++i)
    {
        seaSprite[i].position = ccp(dispX+dir[i]*(sin((2*kmPI*time*freq[i])+phase[i])*rangeX),pos[i]+sin(time)*amp[i]);
 
    }
    time += dt*0.2f;
    
    //time = fmod(time,1.0f);
}

-(void) update: (ccTime) dt
{
    const ccTime fixed_dt_ = 1.0f/60.0f;
    accumulator_ += dt;
    
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    
    while ( accumulator_ >= fixed_dt_ )
    {
        [self updateSea:fixed_dt_];
       
        // Instruct the world to perform a single step of simulation. It is
        // generally best to keep the time step and iterations fixed.
        world->Step(fixed_dt_, velocityIterations, positionIterations);
        accumulator_ -= fixed_dt_;
    }
    
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteAtPosition: location];
	}
}


@end
