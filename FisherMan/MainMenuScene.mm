//
//  HelloWorldLayer.mm
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "MainMenuScene.h"
#import "GameScene.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"


enum {
  kMenu,
  kMenuItemAchievements,
  kMenuItemLeaderboard,
};

@interface MainMenuLayer()
-(void) createMenu;
@end

@implementation MainMenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
        [self authenticateLocalPlayer];
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		
		// create reset button
		[self createMenu];
		
		//Set up sprite
		

		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Pick a Fish!" fontName:@"Verdana" fontSize:32];
        CCLabelBMFont* gameTitleLabel = [CCLabelBMFont labelWithString:@"Pick a Fish!" fntFile:@"font-title1.fnt"];
		[self addChild:gameTitleLabel z:0];
		gameTitleLabel.position = ccp( s.width/2, s.height-64);
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{

	[super dealloc];
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *startGame = [CCMenuItemFont itemWithString:@"Start Game" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [GameScene node]];
	}];
    
    
	
	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
		[achivementViewController release];
	}];
	[itemAchievement setTag:kMenuItemAchievements];
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
		[leaderboardViewController release];
	}];
	[itemLeaderboard setTag:kMenuItemLeaderboard];
	CCMenu *menu = [CCMenu menuWithItems:startGame,itemAchievement, itemLeaderboard, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
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

- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            //[viewController sho
            //[self showAuthenticationDialogWhenReasonable: viewController];
            AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
            
            [[app navController] presentModalViewController:viewController animated:YES];
            
        }
        else if (localPlayer.isAuthenticated)
        {
            //gameCenter = true;
            //[self authenticatedPlayer: localPlayer];
        }
        else
        {
            //[self disableGameCenter];
            CCMenu* menu = (CCMenu*)[self getChildByTag:kMenu];
            CCMenuItem* item1 = (CCMenuItem*)(CCMenuItem*)[menu getChildByTag:kMenuItemAchievements];
            CCMenuItem* item2 = (CCMenuItem*)[menu getChildByTag:kMenuItemLeaderboard];
            [item1 setIsEnabled:NO];
            [item2 setIsEnabled:NO];
            
            //gameCenter = false;
            //[[menu getChildByTag:kMenuItemAchievements]
        }
    };
}


-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
