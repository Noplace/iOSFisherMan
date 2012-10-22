#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "Constants.h"
#import "SimpleAudioEngine.h"
#import "GameSettings.h"



@interface GameManager : NSObject <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    BOOL hasPlayerDied;
    SceneTypes currentScene;
    BOOL isGameCenterEnabled;
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;
    NSMutableDictionary *achievementsDictionary;
    NSArray *leaderboardArray;
    id sceneToRun;
    
@public struct
    {
        int currentLevel;
    }gameState;
    
@public struct {
            int lifetimeFishCaught;
            int fingerMovedAndFishLost;
            int fishEscaped;
            int fishLost;
            int fishCaught;
            int fishMissed;
            //int badstuffCaught;
            ccTime completionTime;
        } counters;
    
   
}

@property (nonatomic, retain) GameSettings* settings;
@property (nonatomic, retain) NSMutableDictionary *achievementsDictionary;
@property (readonly) id currentSceneObject;
@property (readonly)  SceneTypes currentScene;
@property (readonly)  BOOL isGameCenterEnabled;
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL hasPlayerDied;
@property (readwrite) GameManagerSoundState managerSoundState;
//@property (readonly) SimpleAudioEngine *soundEngine;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (readonly) CCDirectorDisplayLink* director;
@property (nonatomic, retain, readonly) UIWindow* window;

+ (GameManager*) sharedGameManager;
- (void) setupGraphics: (id<CCDirectorDelegate>) dirDelegate;
- (void) runSceneWithID:(SceneTypes)sceneID;
- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) category;
- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier;
- (void) showAchievements;
- (void) showLeaderboard;
- (void) openSiteWithLinkType:(LinkTypes)linkTypeToOpen;
- (void) authenticateLocalPlayer: (SEL) onResult object: (id) object;
- (void) setupAudioEngine;
- (ALuint) playSoundEffect:(NSString*)soundEffectKey;
- (void) stopSoundEffect:(ALuint)soundEffectID;
- (void) playBackgroundTrack:(NSString*)trackFileName;

@end
