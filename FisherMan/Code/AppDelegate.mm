//
//  AppDelegate.mm
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 9/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroScene.h"

@implementation AppController

@synthesize navController=navController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    gameManager = [GameManager sharedGameManager];
    [gameManager setupAudioEngine];
    [gameManager setupGraphics:self];
    /*
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];

	director_ = (CCDirectorDisplayLink*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
    [director_ enableRetinaDisplay:YES];
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	//if( ! [director_ enableRetinaDisplay:YES] )
	//	CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	
	*/
    
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
    // and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	//[director_ pushScene: [IntroScene scene]];
	[gameManager runSceneWithID:kIntroScene];
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:gameManager.director];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
    //	[window_ addSubview:navController_.view];	// Generates flicker.
	[gameManager.window setRootViewController:navController_];
	
	// make main window visible
	[gameManager.window makeKeyAndVisible];
    
    
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == gameManager.director )
		[gameManager.director pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == gameManager.director )
		[gameManager.director resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == gameManager.director )
		[gameManager.director stopAnimation];
    

}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    
    if (gameManager.currentScene == kMainMenuScene)
    {
        //run checkGameCenter method of the layer inside the mainmenu scene
        [gameManager authenticateLocalPlayer:@selector(checkGameCenter) object:[[gameManager.currentSceneObject children] objectAtIndex:0 ]];
    }
    else
    {
        [gameManager authenticateLocalPlayer:nil object:nil];
    }
	if( [navController_ visibleViewController] == gameManager.director )
		[gameManager.director startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[gameManager.director purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[gameManager.director setNextDeltaTimeZero:YES];
}

- (void) dealloc
{

    [gameManager release];
	[navController_ release];
	
	[super dealloc];
}
@end
