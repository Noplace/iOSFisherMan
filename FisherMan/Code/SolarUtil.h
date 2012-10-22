//
//  SolarUtil.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/4/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SolarUtil : NSObject
+ (NSUInteger) dayOfYear:(NSDate*) date;
+ (CGPoint) sunPosition:(NSUInteger) dayOfYear year:(float) year hour:(float) hour lat:(float) lat lng:(float) lng;
@end
