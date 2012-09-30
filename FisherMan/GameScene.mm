//
//  GameScene.m
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "GameScene.h"
#import "MainMenuScene.h"
#import "time.h"

@interface GameScene()
{
    BackgroundLayer *bgLayer;
    SeaLayer *seaLayer;
    ccTime timeOfDay_;
    float gameSpeed_;
    CCLabelTTF* debugLabel;
}
-(void) initPhysics;
+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor;
- (void) createMenu;
- (void)showConfirmAlert;
@end

@implementation GameScene

-(id)init
{
    
    self = [super init];
    if (self != nil)
    {
        srandom(time(NULL));
        CGSize size = [CCDirector sharedDirector].winSize;
        gameSpeed_ = 1.0f;
        [self initPhysics];
    
        bgLayer = [BackgroundLayer nodeWithWorld:world];
        seaLayer = [SeaLayer nodeWithWorld:world];
       
        
        debugLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12];
        debugLabel.anchorPoint = ccp(0,0);
        debugLabel.position = ccp(0,size.height-20);
        [self addChild:debugLabel z:100];
        
        [self update:1.0f/60.0f];
        [self addChild:bgLayer z:0];        
        [self addChild:seaLayer z:1];
        [self createMenu];
        [self scheduleUpdate];
        return self;
    }
    return nil;
}


-(void) initPhysics
{
    timer_accumulator_ = 0;
	timeOfDay_ = sunriseStart+3;
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity,true);
	
	
	// Do we want to let bodies sleep?
	//world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(NULL);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0,0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
    
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	// bottom
	
	groundBox.Set(b2Vec2(0,ptm(-s.height)), b2Vec2(ptm(s.width),ptm(-s.height)));
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

+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	[label setColor:cor];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint center = ccp(label.texture.contentSize.width/2+size, label.texture.contentSize.height/2+size);
	[rt begin];
	for (int i=0; i<360; i+=15)
	{
		[label setPosition:ccp(center.x + sin(CC_DEGREES_TO_RADIANS(i))*size, center.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[rt setPosition:originalPos];
	return rt;
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
    
	// Reset Button
    //CCMenuItemImage* test = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon-72.png"];
	CCMenuItemLabel *quitItem = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender){
		//[[CCDirector sharedDirector] replaceScene: [GameScene node]];
        [self showConfirmAlert];
	}];
	
    quitItem.color = ccc3(0,0,0);
	
    
    //CCLabelTTF* label = [CCLabelTTF labelWithString: @"Some Text"
     //                              dimensions:CGSizeMake(305,179) hAlignment:kCCTextAlignmentLeft
     //                                fontName:@"Arial" fontSize:23];
    //[label setPosition:ccp(167,150)];
    //[label setColor:ccWHITE];
    //CCRenderTexture* stroke = [GameScene createStroke:label  size:2  color:ccc3(255,0,255)];
    //[self addChild:stroke];
    //[self addChild:label];
    //CCMenuItemSprite* spriteItem = [CCMenuItemSprite itemWithNormalSprite:[stroke sprite] selectedSprite:label];
	
    
    CCMenu *menu = [CCMenu menuWithItems:quitItem, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width-65, size.height-24)];
	
    
    [self addChild: menu z:100];
}

- (void) draw
{
    [super draw];
    
    //ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    //kmGLPushMatrix();
	//world->DrawDebugData();
	//kmGLPopMatrix();
}

- (void) update: (ccTime) dt
{
    const ccTime fixed_dt_ = 1.0f/60.0f;
    timer_accumulator_ += dt;
    
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    
    while ( timer_accumulator_ >= fixed_dt_ )
    {
        [debugLabel setString:[NSString stringWithFormat:@"time of day: %03.3f",timeOfDay_]];
        bgLayer.timeOfDay = timeOfDay_;
        seaLayer.timeOfDay = timeOfDay_;
        [bgLayer update:fixed_dt_*gameSpeed_];
        [seaLayer update:fixed_dt_*gameSpeed_];  
        // Instruct the world to perform a single step of simulation. It is
        // generally best to keep the time step and iterations fixed.
        world->Step(fixed_dt_*gameSpeed_, velocityIterations, positionIterations);
        
        timeOfDay_ += fixed_dt_*gameSpeed_;
        if (timeOfDay_ > daySeconds)
            timeOfDay_ = 0.0f;
        timer_accumulator_ -= fixed_dt_;
    }
	
}

- (void)showConfirmAlert
{
    
    
    
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Confirm"];
	[alert setMessage:@"Are you sure you want to quit your game and go back to the main menu?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0 scene:[MainMenuLayer scene]]];
	}
	else if (buttonIndex == 1)
	{
		// No
	}
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

@end
