//
//  LevelCompleteScene.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/9/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import "LevelCompleteScene.h"

@interface LevelCompleteScene()
{
    CCLabelBMFont* scoreLabel;
    GameManager* manager;
    float scoreP;
    int64_t topScore;
}
@end

@implementation LevelCompleteScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelCompleteScene *layer = [LevelCompleteScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
	if( (self=[super init])) {
		
        
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		CGSize size = [CCDirector sharedDirector].winSize;
		manager = [GameManager sharedGameManager];
        
		
        
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Pick a Fish!" fontName:@"Verdana" fontSize:32];
        CCLabelBMFont* gameTitleLabel = [CCLabelBMFont labelWithString:@"Level Complete!" fntFile:@"font-title1.fnt"];
		[self addChild:gameTitleLabel z:0];
		gameTitleLabel.position = ccp( size.width/2, size.height-gameTitleLabel.contentSize.height);
        scoreLabel = [CCLabelBMFont labelWithString:@"Score: 0" fntFile:@"font-title1.fnt" width:size.width alignment:kCCTextAlignmentCenter ];
		scoreLabel.position = ccp( size.width/2, (size.height/2)-10);
        scoreLabel.visible = NO;
        
        
        topScore = [manager.settings getLevelTopScore:manager->gameState.currentLevel];
        [self addChild:scoreLabel];
        {
            id delay = [CCDelayTime actionWithDuration:2.0f];
            id show1 = [CCShow action];
            id callfunc = [CCCallFunc actionWithTarget:self selector:@selector(startCount)];
            id seq = [CCSequence actions:delay,show1,callfunc, nil];
            [scoreLabel runAction:seq];
        }
        
        
	}
	return self;
}

- (void) dealloc
{
    
	[super dealloc];
}

- (void) startCount
{
    scoreP = 0;
    [self scheduleUpdate];
}

- (void) reportScore
{
 
    [manager.settings save];
    
    NSString* leaderboard;
    NSString* difficultyStr;
    switch ([manager.settings.difficulty intValue])
    {
        case 0:difficultyStr = @"Easy"; break;
        case 1:difficultyStr = @"Medium"; break;
        case 2:difficultyStr = @"Hard"; break;
    }
    
    leaderboard = [NSString stringWithFormat:@"Level%dScore%@",manager->gameState.currentLevel+1,difficultyStr];
    [manager reportScore:topScore forLeaderboardID:leaderboard];
}


-(void) createMenu
{
    CGSize size = [[CCDirector sharedDirector] winSize];
	[CCMenuItemFont setFontSize:22];
	
	CCMenuItemLabel *startGame = [CCMenuItemFont itemWithString:@"Next Level" block:^(id sender){
        switch (manager->gameState.currentLevel)
        {
            case 0: [manager runSceneWithID:kGameLevel2]; break;
            case 1: [manager runSceneWithID:kGameLevel3]; break;
            case 2: [manager runSceneWithID:kGameLevel4]; break;
            case 3: [manager runSceneWithID:kGameLevel5]; break;
            case 4: [manager runSceneWithID:kMainMenuScene]; break;//change diff or go mainmenu break;
        }
	}];
    
	
	CCMenuItem *exitToMainMenu = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender) {
		
        [manager runSceneWithID:kMainMenuScene];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:exitToMainMenu,startGame, nil];
	
	[menu alignItemsHorizontallyWithPadding:size.width/2];
	
	[menu setPosition:ccp( size.width/2, 22)];
	
	[self addChild: menu];
}

- (void) update:(ccTime) dt
{
    if (scoreP >= topScore)
    {
        scoreP = topScore;
        [self reportScore];
        [self pauseSchedulerAndActions];
        [self createMenu];
        
    }
    [scoreLabel setString:[NSString stringWithFormat:@"Score:\n %.0f",scoreP]];
     scoreP += dt*topScore / 4.0f;
    
        
     
}

@end
