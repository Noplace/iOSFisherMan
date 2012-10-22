//
//  GameSky.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/9/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameModel.h"

@interface GameSky : NSObject

@property (readonly) GameModel* model;
- (id) initWithModel:(GameModel*) gameModel;
- (void) update: (ccTime) dt;
- (void) randomizeStars;
@end
