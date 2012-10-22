//
//  AppDelegate.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{

	UINavigationController *navController_;
	GameManager* gameManager;
	
}

@property (readonly) UINavigationController *navController;


@end
