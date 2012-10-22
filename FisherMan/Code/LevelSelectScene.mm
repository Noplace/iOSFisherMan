//
//  LevelSelectScene.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/21/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import "LevelSelectScene.h"
#import "CCControlExtension.h"


@implementation LevelSelectScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelSelectScene *layer = [LevelSelectScene node];
	
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
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSArray *stringArray = [NSArray arrayWithObjects:@"Hello",@"Variable",@"Size",@"!", nil];
        
        CCNode *layer = [CCNode node];
        [self addChild:layer z:1];
        
        double total_width = 0, height = 0;
        
        // For each title in the array
        for (NSString *title in stringArray)
        {
            // Creates a button with this string as title
            CCControlButton *button = [self standardButtonWithTitle:title];
            [button setPosition:ccp (total_width + button.contentSize.width / 2, button.contentSize.height / 2)];
            [layer addChild:button];
            
            // Compute the size of the layer
            height = button.contentSize.height;
            total_width += button.contentSize.width;
        }
        
        [layer setAnchorPoint:ccp (0.5, 0.5)];
        [layer setContentSize:CGSizeMake(total_width, height)];
        [layer setPosition:ccp(screenSize.width / 2.0f, screenSize.height / 2.0f)];
        
        // Add the black background
        CCScale9Sprite *background = [CCScale9Sprite spriteWithFile:@"buttonBackground.png"];
        [background setContentSize:CGSizeMake(total_width + 14, height + 14)];
        [background setPosition:ccp(screenSize.width / 2.0f, screenSize.height / 2.0f)];
        [self addChild:background];
        
        
	}
	return self;
}

-(void) dealloc
{
    
	[super dealloc];
}

- (CCControlButton *)standardButtonWithTitle:(NSString *)title
{
    /** Creates and return a button with a default background and title color. */
    CCScale9Sprite *backgroundButton = [CCScale9Sprite spriteWithFile:@"button.png"];
    [backgroundButton setPreferedSize:CGSizeMake(45, 45)];  // Set the prefered size
    CCScale9Sprite *backgroundHighlightedButton = [CCScale9Sprite spriteWithFile:@"buttonHighlighted.png"];
    [backgroundHighlightedButton setPreferedSize:CGSizeMake(45, 45)];  // Set the prefered size
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    CCLabelTTF *titleButton = [CCLabelTTF labelWithString:title fontName:@"HelveticaNeue-Bold" fontSize:30];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
    CCLabelTTF *titleButton = [CCLabelTTF labelWithString:title fontName:@"Marker Felt" fontSize:30];
#endif
    [titleButton setColor:ccc3(159, 168, 176)];
    
    CCControlButton *button = [CCControlButton buttonWithLabel:titleButton backgroundSprite:backgroundButton];
    [button setBackgroundSprite:backgroundHighlightedButton forState:CCControlStateHighlighted];
    [button setTitleColor:ccWHITE forState:CCControlStateHighlighted];
    
    return button;
}

@end
