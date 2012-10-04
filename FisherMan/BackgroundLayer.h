//
//  BackgroundLayer.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "GameLayer.h"


@interface BackgroundLayer : GameLayer


- (void) update: (ccTime) dt;

- (void) setWeatherCondition: (WeatherCondition) cond Enable:(BOOL) enable Intensity: (float) intensity;

@end
