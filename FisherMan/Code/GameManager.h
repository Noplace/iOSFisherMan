//  GameManager.h
//  SpaceViking
//
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Constants.h"
#import "SimpleAudioEngine.h"

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
    
}
@property (readonly)  BOOL isGameCenterEnabled;
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL hasPlayerDied;
@property (readwrite) GameManagerSoundState managerSoundState;
//@property (readonly) SimpleAudioEngine *soundEngine;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;

+ (GameManager*) sharedGameManager;
- (void) runSceneWithID:(SceneTypes)sceneID;
- (void) showAchievements;
- (void) showLeaderboard;
- (void) openSiteWithLinkType:(LinkTypes)linkTypeToOpen;
- (void) authenticateLocalPlayer: (SEL) onResult object: (id) object;
- (void) setupAudioEngine;
- (ALuint) playSoundEffect:(NSString*)soundEffectKey;
- (void) stopSoundEffect:(ALuint)soundEffectID;
- (void) playBackgroundTrack:(NSString*)trackFileName;

@end
