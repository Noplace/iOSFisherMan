//
//  GameSettings.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/16/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSettings : NSObject

@property (nonatomic,copy) NSNumber* gameSpeed;
@property (nonatomic,copy) NSNumber* difficulty;
@property (nonatomic,copy) NSNumber* levelsCompleted;
@property (nonatomic,retain) NSMutableArray* topScoreEasy;

- (int64_t) getLevelTopScore : (int) level;
- (void) setLevel: (int) level TopScore: (int64_t) score;
- (void) load;
- (void) save;

@end
