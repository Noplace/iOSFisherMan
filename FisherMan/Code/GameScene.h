//
//  GameScene.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GameModel.h"


@interface GameScene : CCLayer <UIAlertViewDelegate,SeaObjectEventsReceiever>
{
    
    GLESDebugDraw *m_debugDraw;		// strong ref
    ccTime timer_accumulator_;
}

+(CCScene *) scene;
@end
