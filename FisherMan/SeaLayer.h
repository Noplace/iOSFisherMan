//
//  HelloWorldLayer.h
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "GameLayer.h"



// HelloWorldLayer
@interface SeaLayer : GameLayer
{
	CCTexture2D *spriteTexture_;	// weak ref
    CCSpriteBatchNode *seaObjectsParentNode;
    CCSpriteBatchNode* seaParentNode;
    CCSprite* seaSprite[4];
}


- (void) update: (ccTime) dt;

@end
