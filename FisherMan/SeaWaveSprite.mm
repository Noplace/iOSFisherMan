//
//  SeaWaveSprite.m
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//
//

#import "SeaWaveSprite.h"

@implementation SeaWaveSprite
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
	//b2Vec2 pos  = body_->GetPosition();
	
	float x = 0;//pos.x * PTM_RATIO;
	float y = 0;//pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = 0;
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		//x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		//y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );
	
	return transform_;
}

-(void) dealloc
{
	//
	[super dealloc];
}

@end
