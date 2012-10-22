//
//  OptionsScene.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/10/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import "OptionsScene.h"
#import "CCControlExtension.h"

@interface OptionsScene()
{
    CCControlSlider* slider;
    CCLabelBMFont* difficultyLabel;
}
@end

@implementation OptionsScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	OptionsScene *layer = [OptionsScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
        
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		CGSize size = [CCDirector sharedDirector].winSize;
        [CCMenuItemFont setFontSize:16];
        CCMenuItem *itemDiffPrev = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender) {
            [GameManager sharedGameManager].settings.difficulty = [NSNumber numberWithInt:slider.value];
            [[GameManager sharedGameManager].settings save];
            [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
            
        }];
        
        CCMenuItem *itemDiffTitle = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Test" fontName:@"Arial" fontSize:16] ];
        
        CCMenuItem *itemDiffNext = [CCMenuItemFont itemWithString:@"Next" block:^(id sender) {
            
        }];
        
        CCMenu *menu = [CCMenu menuWithItems:itemDiffPrev,itemDiffTitle,itemDiffNext, nil];
        
        [menu alignItemsHorizontally];
        
        [menu setPosition:ccp( size.width/2, (size.height/2)-30)];
        difficultyLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"font-score-time.fnt"];
        
        slider = [CCControlSlider sliderWithBackgroundFile:@"sliderTrack.png" progressFile:@"sliderProgress.png" thumbFile:@"sliderThumb.png"];
        slider.maximumValue = 2;
        slider.minimumValue = 0;
        slider.value = [[GameManager sharedGameManager].settings.difficulty intValue];
        slider.position = ccp(size.width/2,size.height/2);
        [slider addTarget:self action:@selector(valueChanged:) forControlEvents:CCControlEventValueChanged];
        difficultyLabel.position = ccp(100+size.width/2,size.height/2);
        [self addChild:slider];
        [self addChild:difficultyLabel];
        [self addChild: menu z:10];
        //[self scheduleUpdate];
        [self valueChanged:slider];
	}
	return self;
}

-(void) dealloc
{
    
	[super dealloc];
}


- (void) valueChanged:(CCControlSlider *)sender
{
    int diff =  (int)round(sender.value);
    switch (diff)
    {
        case 0:    [difficultyLabel setString:[NSString stringWithFormat:@"Easy"]]; break;
        case 1:    [difficultyLabel setString:[NSString stringWithFormat:@"Medium"]]; break;
        case 2:    [difficultyLabel setString:[NSString stringWithFormat:@"Hard"]]; break;
            
    }
}

- (void) update:(ccTime) dt
{
    
}


@end
