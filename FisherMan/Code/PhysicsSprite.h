//
//  PhysicsSprite.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 1/4/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

@interface PhysicsSprite : CCSprite
{
@public	b2Body *body_;	// strong ref
}

@property ccTime timeAlive;
@property int type;
-(void) setPhysicsBody:(b2Body*)body;
@end