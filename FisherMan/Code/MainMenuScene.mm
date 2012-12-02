//
//  HelloWorldLayer.mm
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "MainMenuScene.h"


enum {
  kMenu,
  kMenuItemAchievements,
  kMenuItemLeaderboard,
};

@interface MainMenuScene()
-(void) createMenu;
@end

@implementation MainMenuScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuScene *layer = [MainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
        [[GameManager sharedGameManager].settings load];
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		CGSize size = [CCDirector sharedDirector].winSize;
		
		
		
		CCSprite* backgroundSprite = [CCSprite spriteWithFile:@"bg.png"];
        backgroundSprite.position = ccp(size.width/2, size.height/2);
        [self addChild:backgroundSprite z:-1];
		

		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Pick a Fish!" fontName:@"Verdana" fontSize:32];
        CCLabelBMFont* gameTitleLabel = [CCLabelBMFont labelWithString:@"Pick a Fish!" fntFile:@"font-title1.fnt"];
        [gameTitleLabel setScale:0];
		[self addChild:gameTitleLabel z:0];
		gameTitleLabel.position = ccp( size.width/2, size.height-gameTitleLabel.contentSize.height);
        
        // create reset button
		[self createMenu];
        
        
        [self checkGameCenter];

        [[GameManager sharedGameManager] authenticateLocalPlayer:@selector(checkGameCenter) object:self];
        
       
        //gameCenter = false;
        //[[menu getChildByTag:kMenuItemAchievements]
        
		//[self scheduleUpdate];
        
        /* game title animation */
        {
            id scale1 = [CCScaleTo actionWithDuration:2.0f scale:1.3f];
            id scale2 = [CCScaleTo actionWithDuration:0.5f scale:1.0f];
            id rotate1 = [CCRotateTo actionWithDuration:0.5f angle:180];
            id rotate2 = [CCRotateTo actionWithDuration:0.5f angle:360];
            id delay1 = [CCDelayTime actionWithDuration:3.0f];
            id scale3 = [CCScaleTo actionWithDuration:2.0f scale:0];
            id delay2 = [CCDelayTime actionWithDuration:1.0f];
            id seqAction = [CCSequence actions:scale1,scale2,rotate1,rotate2,delay1,scale3,delay2,nil];
            [gameTitleLabel runAction:[CCRepeat actionWithAction:seqAction times:100]];
        }
	}
	return self;
}

-(void) dealloc
{

	[super dealloc];
}

- (void) checkGameCenter
{
    //if ( == NO)
    {
        CCMenu* menu = (CCMenu*)[self getChildByTag:kMenu];
        CCMenuItem* item1 = (CCMenuItem*)(CCMenuItem*)[menu getChildByTag:kMenuItemAchievements];
        CCMenuItem* item2 = (CCMenuItem*)[menu getChildByTag:kMenuItemLeaderboard];
        [item1 setIsEnabled:[[GameManager sharedGameManager] isGameCenterEnabled]];
        [item2 setIsEnabled:[[GameManager sharedGameManager] isGameCenterEnabled]];
    }
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *startGame = [CCMenuItemFont itemWithString:@"Start Game" block:^(id sender){
		//[[CCDirector sharedDirector] replaceScene: [GameScene node]];
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel1];
	}];
    
    
	
	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		[[GameManager sharedGameManager] showAchievements];
	}];
	[itemAchievement setTag:kMenuItemAchievements];
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		[[GameManager sharedGameManager] showLeaderboard];
		
	}];
	[itemLeaderboard setTag:kMenuItemLeaderboard];
    
   	CCMenuItem *itemOptions = [CCMenuItemFont itemWithString:@"Options" block:^(id sender) {
		[[GameManager sharedGameManager] runSceneWithID:kOptionsScene];
		
	}];
    
    CCMenuItem *itemGameGuide = [CCMenuItemFont itemWithString:@"Game Guide" block:^(id sender) {
		
		
	}];
	CCMenu *menu = [CCMenu menuWithItems:startGame,itemAchievement,itemLeaderboard,itemOptions,itemGameGuide, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, (size.height/2)-30)];
	
	
	[self addChild: menu z:-1 tag:kMenu];
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	//ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	//kmGLPushMatrix();
	
	//world->DrawDebugData();
	
	//kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
    //const ccTime fixed_dt_ = 1.0f/60.0f;
    //accumulator_ += dt;
    
    //int32 velocityIterations = 8;
    //int32 positionIterations = 1;
    
    //while ( accumulator_ >= fixed_dt_ )
    {
        // Instruct the world to perform a single step of simulation. It is
        // generally best to keep the time step and iterations fixed.
        //world->Step(fixed_dt_, velocityIterations, positionIterations);
        //accumulator_ -= fixed_dt_;
    }
    
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		
	}
}



@end
