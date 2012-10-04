//
//  HelloWorldLayer.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "GameLayer.h"



// HelloWorldLayer
@interface SeaLayer : GameLayer


- (void) update: (ccTime) dt;
- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity;
@end
