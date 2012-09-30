//
//  GameScene.h
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "BackgroundLayer.h"
#import "SeaLayer.h"

@interface GameScene : CCScene <UIAlertViewDelegate>
{
    GLESDebugDraw *m_debugDraw;		// strong ref
    b2World* world;
    ccTime timer_accumulator_;
}
-(id)init;

@end
