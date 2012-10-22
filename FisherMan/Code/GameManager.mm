//  GameManager.m
//  SpaceViking
//
#import "AppDelegate.h"
#import "GameManager.h"
#import "MainMenuScene.h"
#import "IntroScene.h"
#import "GameScene.h"
#import "LevelCompleteScene.h"
#import "OptionsScene.h"
#import "LevelSelectScene.h"


@implementation GameManager
static GameManager* _sharedGameManager = nil;                      // 1
@synthesize settings;
@synthesize currentSceneObject=sceneToRun;
@synthesize currentScene;
@synthesize isGameCenterEnabled;
@synthesize isMusicON;
@synthesize isSoundEffectsON;
@synthesize hasPlayerDied;
@synthesize managerSoundState;
@synthesize listOfSoundEffectFiles;
@synthesize soundEffectsState;
@synthesize director;
@synthesize window;
@synthesize achievementsDictionary;


+(GameManager*)sharedGameManager {
    @synchronized([GameManager class])                             // 2
    {
        if(!_sharedGameManager)                                    // 3
            [[self alloc] init]; 
        return _sharedGameManager;                                 // 4
    }
    return nil; 
}

+(id)alloc
{
    @synchronized ([GameManager class])                            // 5
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocated a second instance of the Game Manager singleton");                                          // 6
        _sharedGameManager = [super alloc];
        return _sharedGameManager;                                 // 7
    }
    return nil;  
}

-(id)init {                                                        // 8
    self = [super init];
    if (self != nil) {
        // Game Manager initialized
        NSLog(@"Game Manager Singleton, init");
        isGameCenterEnabled = NO;
        isMusicON = YES;
        isSoundEffectsON = YES;
        hasPlayerDied = NO;
        currentScene = kNoSceneUninitialized;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        achievementsDictionary = [[NSMutableDictionary alloc] init];
        
        memset(&counters,0,sizeof(counters));
        
        
        
        //load from user profile or something
        settings = [[GameSettings alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [window release];
    [settings release];
}

- (void) setupGraphics: (id<CCDirectorDelegate>) dirDelegate
{
    // Create the main window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
    // Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    
	director = (CCDirectorDisplayLink*)[CCDirector sharedDirector];
	
	director.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director setDisplayStats:YES];
	
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director setView:glView];
	
	// for rotation and other messages
	[director setDelegate:dirDelegate];
	
	// 2D projection
	[director setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
    [director enableRetinaDisplay:YES];
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	//if( ! [director_ enableRetinaDisplay:YES] )
	//	CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
}




- (void) loadLeaderboardInfo
{
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        leaderboardArray = leaderboards;
    }];
}

- (void) displayGameCenterMessage
{

}

- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) category
{
    if (isGameCenterEnabled == NO)
        return;
    
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        NSString* title = @"Score Updated";
        NSString* message = [NSString stringWithFormat: @"Check your new top score for Level %d", gameState.currentLevel+1 ];
        [GKNotificationBanner showBannerWithTitle: title message: message completionHandler:nil];
    }];
}

- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier
{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    return achievement;
}

- (void) loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error != nil)
        {
            // Handle the error.
        }
        if (achievements != nil)
        {
            for (GKAchievement* achievement in achievements)
                [achievementsDictionary setObject: achievement forKey: achievement.identifier];
            // Process the array of achievements.
        }
    }];
}

- (void) authenticateLocalPlayer: (SEL) onResult object: (id) object
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    isGameCenterEnabled = NO;
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            //[viewController sho
            //[self showAuthenticationDialogWhenReasonable: viewController];
            AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
            
            [[app navController] presentModalViewController:viewController animated:YES];
            
        }
        else if (localPlayer.isAuthenticated)
        {
            isGameCenterEnabled = YES;
            [object performSelector:onResult];
            [self loadAchievements];
            [self loadLeaderboardInfo];
        }
        else
        {
            isGameCenterEnabled = NO;
            [object performSelector:onResult];
            
        }
    };
}


-(void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) && 
        (managerSoundState != kAudioManagerFailed)) {
        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || 
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }

    if (managerSoundState == kAudioManagerReady) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
    }
}

-(void)stopSoundEffect:(ALuint)soundEffectID {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopEffect:soundEffectID];
    }
}

-(ALuint)playSoundEffect:(NSString*)soundEffectKey {
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady) {
        NSNumber *isSFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isSFXLoaded boolValue] == SFX_LOADED) {
            soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey]];
        } else {
            NSLog(@"GameMgr: SoundEffect %@ is not loaded, cannot play.",soundEffectKey);
        }
    } else {
        NSLog(@"GameMgr: Sound Manager is not ready, cannot play %@", soundEffectKey);
    }
    return soundID;
}

- (NSString*) formatSceneTypeToString:(SceneTypes)sceneID {
    NSString *result = nil;
    switch(sceneID) {
        case kNoSceneUninitialized:
            result = @"kNoSceneUninitialized";
            break;
        case kMainMenuScene:
            result = @"kMainMenuScene";
            break;
        case kOptionsScene:
            result = @"kOptionsScene";
            break;
        case kCreditsScene:
            result = @"kCreditsScene";
            break;
        case kIntroScene:
            result = @"kIntroScene";
            break;
        case kLevelSelectScene:
            result = @"kLevelSelectScene";
            break;
        case kLevelCompleteScene:
            result = @"kLevelCompleteScene";
            break;
        case kGameLevel1:
            result = @"kGameLevel1";
            break;
        case kGameLevel2:
            result = @"kGameLevel2";
            break;
        case kGameLevel3:
            result = @"kGameLevel3";
            break;
        case kGameLevel4:
            result = @"kGameLevel4";
            break;
        case kGameLevel5:
            result = @"kGameLevel5";
            break;
        case kCutSceneForLevel2:
            result = @"kCutSceneForLevel2";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType."];
    }
    return result;
}

-(NSDictionary *)getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
    NSString *fullFileName = @"Audio-SoundEffects.plist";
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) 
     objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] 
                     pathForResource:@"Audio-SoundEffects" ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = 
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        NSLog(@"Error reading SoundEffects.plist");
        return nil; // No Plist Dictionary or file found
    }
    
    // 4. If the list of soundEffectFiles is empty, load it
    if ((listOfSoundEffectFiles == nil) || 
        ([listOfSoundEffectFiles count] < 1)) {
        NSLog(@"Before");
        [self setListOfSoundEffectFiles:
         [[NSMutableDictionary alloc] init]];
        NSLog(@"after");
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [listOfSoundEffectFiles 
             addEntriesFromDictionary:
             [plistDictionary objectForKey:sceneSoundDictionary]];
        }
        NSLog(@"Number of SFX filenames:%d", 
              [listOfSoundEffectFiles count]);
    }
    
    // 5. Load the list of sound effects state, mark them as unloaded
    if ((soundEffectsState == nil) || 
        ([soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *SoundEffectKey in listOfSoundEffectFiles) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:SoundEffectKey];
        }
    }
    
    // 6. Return just the mini SFX list for this scene
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = 
    [plistDictionary objectForKey:sceneIDName];
    
    return soundEffectsList;
}


-(void)loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    SceneTypes sceneID = (SceneTypes) [sceneIDNumber intValue];
    // 1
    if (managerSoundState == kAudioManagerInitializing) {
            int waitCycles = 0;
            while (waitCycles < AUDIO_MAX_WAITTIME) {
                [NSThread sleepForTimeInterval:0.1f];
                if ((managerSoundState == kAudioManagerReady) || 
                    (managerSoundState == kAudioManagerFailed)) {
                    break;
                }
                waitCycles = waitCycles + 1;
            }
   }
    
    if (managerSoundState == kAudioManagerFailed) {
        return; // Nothing to load, CocosDenshion not ready
    }

    NSDictionary *soundEffectsToLoad = 
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToLoad == nil) { // 2
        NSLog(@"Error reading SoundEffects.plist");
        return;
    }
    // Get all of the entries and PreLoad // 3
    for( NSString *keyString in soundEffectsToLoad )
    {
        NSLog(@"\nLoading Audio Key:%@ File:%@", 
              keyString,[soundEffectsToLoad objectForKey:keyString]);
        [soundEngine preloadEffect:
         [soundEffectsToLoad objectForKey:keyString]]; // 3
        // 4
        [soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
        
    }
    [pool release];
}

-(void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (sceneID == kNoSceneUninitialized) {
        return; // Nothing to unload
    }
    
    
    NSDictionary *soundEffectsToUnload = 
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToUnload == nil) {
        NSLog(@"Error reading SoundEffects.plist");
        return;
    }
    if (managerSoundState == kAudioManagerReady) {
        // Get all of the entries and unload
        for( NSString *keyString in soundEffectsToUnload )
        {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [soundEngine unloadEffect:keyString];
            NSLog(@"\nUnloading Audio Key:%@ File:%@", 
                  keyString,[soundEffectsToUnload objectForKey:keyString]);
            
        }
    }
    [pool release];
}




-(void)initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing; 
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if 
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    //Wait for the audio manager to initialise
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) 
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || 
        audioManager.soundEngine.functioning == NO) {
        NSLog(@"CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed; 
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        NSLog(@"CocosDenshion is Ready");
    }
}


-(void)setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES; 
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncSetupOperation = 
        [[NSInvocationOperation alloc] initWithTarget:self 
                                             selector:@selector(initAudioAsync) 
                                               object:nil];
        [queue addOperation:asyncSetupOperation];
        [asyncSetupOperation autorelease];
    }
}



-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    sceneToRun = nil;
    int transitionType = 0;
    switch (sceneID) {
        case kMainMenuScene: 
            sceneToRun = [MainMenuScene scene];
            transitionType = 1;
            break;
        case kOptionsScene:
            sceneToRun = [OptionsScene node];
            break;
        case kCreditsScene:
            //sceneToRun = [CreditsScene node];
            break;
        case kIntroScene:
            sceneToRun = [IntroScene scene];
            transitionType = 1;
            break;
        case kLevelSelectScene:
            sceneToRun = [LevelSelectScene node];
            break;
        case kLevelCompleteScene:
            sceneToRun = [LevelCompleteScene node];
            transitionType = 2;
            break;
        case kGameLevel1:
            gameState.currentLevel = 0;
            sceneToRun = [GameScene scene];
            break;
        case kGameLevel2:
            gameState.currentLevel = 1;
            sceneToRun = [GameScene scene];
            break;
        case kGameLevel3:
            gameState.currentLevel = 2;
            sceneToRun = [GameScene scene];
            break;
            
        case kGameLevel4:
            gameState.currentLevel = 3;
            sceneToRun = [GameScene scene];
            break;
        case kGameLevel5:
            gameState.currentLevel = 4;
            sceneToRun = [GameScene scene];
            break;
        case kCutSceneForLevel2:
            // Placeholder for Platform Level
            break;
            
        default:
            NSLog(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }

    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }

    
    /*// Menu Scenes have a value of < 100
    if (sceneID < 100) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { 
            CGSize screenSize = director.winSizeInPixels; 
            if (screenSize.width == 960.0f) {
                // iPhone 4 Retina
                [sceneToRun setScaleX:0.9375f];
                [sceneToRun setScaleY:0.8333f];
                NSLog(@"GameMgr:Scaling for iPhone 4 (retina)");
                
            } else {
                [sceneToRun setScaleX:0.4688f];
                [sceneToRun setScaleY:0.4166f];
                NSLog(@"GameMgr:Scaling for iPhone 3GS or older (non-retina)");
                
            }
        }
    }*/
    
    [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:currentScene]];
    
    if ([director runningScene] == nil) {
        [director runWithScene:sceneToRun];
        
    } else {
        if (transitionType == 0)
            [director replaceScene:sceneToRun];
        else if (transitionType == 1)
            [director replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:sceneToRun withColor:ccWHITE]];
        else if (transitionType == 2)
            [director replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0 scene:sceneToRun]];
    }
    [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
     currentScene = sceneID;
}


- (void) showAchievements
{
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:achivementViewController animated:YES];
    
    [achivementViewController release];
}

- (void) showLeaderboard
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
    
    [leaderboardViewController release];
}

- (void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen {
    NSURL *urlToOpen = nil;
    if (linkTypeToOpen == kLinkTypeBookSite) {
        NSLog(@"Opening Book Site");
        urlToOpen = 
        [NSURL URLWithString:
         @"http://www.informit.com/title/9780321735621"];
    } else if (linkTypeToOpen == kLinkTypeDeveloperSiteRod) {
        NSLog(@"Opening Developer Site for Rod");
        urlToOpen = [NSURL URLWithString:@"http://www.prop.gr"];
    } else if (linkTypeToOpen == kLinkTypeDeveloperSiteRay) {
        NSLog(@"Opening Developer Site for Ray");
        urlToOpen = 
        [NSURL URLWithString:@"http://www.raywenderlich.com/"];
    } else if (linkTypeToOpen == kLinkTypeArtistSite) {
        NSLog(@"Opening Artist Site");
        urlToOpen = [NSURL URLWithString:@"http://EricStevensArt.com"];
    } else if (linkTypeToOpen == kLinkTypeMusicianSite) {
        NSLog(@"Opening Musician Site");
        urlToOpen = 
        [NSURL URLWithString:@"http://www.mikeweisermusic.com/"];
    } else {
        NSLog(@"Defaulting to Cocos2DBook.com Blog Site");
        urlToOpen = 
        [NSURL URLWithString:@"http://www.cocos2dbook.com"];
    }
    
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        NSLog(@"%@%@",@"Failed to open url:",[urlToOpen description]);
        [self runSceneWithID:kMainMenuScene];
    }    
}


-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
