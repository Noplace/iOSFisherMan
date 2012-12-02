//
//  PhysicsSprite.mm
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "PhysicsSprite.h"
#import "GameUtil.h"
// Needed PTM_RATIO

#pragma mark - PhysicsSprite
@implementation PhysicsSprite

@synthesize timeAlive,type;

-(void) setPhysicsBody:(b2Body *)body
{
	body_ = body;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{	
	b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	position_.x = x;
    position_.y = y;
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = body_->GetAngle();
    float r2 = -CC_DEGREES_TO_RADIANS(rotation_);
	float c = cosf(radians+r2);
	float s = sinf(radians+r2);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Rot, Translate Matrix
   
	transform_ = CGAffineTransformMake( c*scaleX_,  s,
									   -s,	c*scaleY_,
									   x,	y );
	
	return transform_;
}

-(void) dealloc
{
	// 
	[super dealloc];
}

@end
