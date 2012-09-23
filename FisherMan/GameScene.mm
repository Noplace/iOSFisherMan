//
//  GameScene.m
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "GameScene.h"
#import "MainMenuScene.h"

@interface GameScene()
- (void) createMenu;
- (void)showConfirmAlert;
@end

@implementation GameScene

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        BackgroundLayer *bgLayer = [BackgroundLayer node];
        [self addChild:bgLayer z:0];
        SeaLayer *seaLayer = [SeaLayer node];
        [self addChild:seaLayer z:1];
        [self createMenu];
        return self;
    }
    return nil;
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
	CCMenu *menu = [CCMenu menuWithItems:quitItem, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width-65, size.height-24)];
	
	
	[self addChild: menu z:100];
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

@end
