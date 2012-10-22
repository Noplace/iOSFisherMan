//
//  GameSettings.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/16/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import "GameSettings.h"

@interface GameSettings()
{
    
}
@end

@implementation GameSettings

@synthesize gameSpeed;
@synthesize difficulty,levelsCompleted;
@synthesize topScoreEasy;

- (id) init
{
    if (self = [super init])
    {
        
        [self load];
        return self;
    }
    
    return nil;
}


- (void) dealloc
{
    [super dealloc];
}

- (int64_t) getLevelTopScore : (int) level
{
    NSMutableArray* arr;
    switch ([difficulty intValue])
    {
        case 0: arr = topScoreEasy; break;
        case 1: arr = topScoreEasy; break;
        case 2: arr = topScoreEasy; break;
    }
    
    NSNumber* topScore = [arr objectAtIndex:level];
    return [topScore longLongValue];
}


- (void) setLevel: (int) level TopScore: (int64_t) score
{
    NSMutableArray* arr;
    switch ([difficulty intValue])
    {
        case 0: arr = topScoreEasy; break;
        case 1: arr = topScoreEasy; break;
        case 2: arr = topScoreEasy; break;
    }
    
    NSNumber* topScore = [NSNumber numberWithLongLong:score];
    
    [arr replaceObjectAtIndex:level withObject:topScore];
}

- (void) load
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    //NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
    //                                                          NSUserDomainMask, YES) objectAtIndex:0];
    //plistPath = [rootPath stringByAppendingPathComponent:@"GameSettings.plist"];
    //if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
    NSString *plistPath;
    plistPath = [[NSBundle mainBundle] pathForResource:@"GameSettings" ofType:@"plist"];
    //}
    //NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSDictionary dictionaryWithContentsOfFile:plistPath];/*[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];*/
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    self.gameSpeed =[temp objectForKey:@"gameSpeed"];
    self.difficulty = [temp objectForKey:@"difficulty"];
    self.levelsCompleted = [temp objectForKey:@"levelsCompleted"];
 
    //for( NSString *aKey in temp )
    {
       // NSLog(@"key %@",aKey);
    }
    
    //NSArray* tempArray = [temp objectForKey:@"topScoreEasy"];
    self.topScoreEasy = [NSMutableArray arrayWithArray:[temp objectForKey:@"topScoreEasy"]];
    //NSLog(@"gameSpeed %f,array count %d",[self.gameSpeed floatValue],tempArray.count);
}

- (void) save
{
    NSString *error;
    //NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *plistPath = [rootPath stringByAppendingPathComponent:@"GameSettings.plist"];
    NSString *plistPath;
    plistPath = [[NSBundle mainBundle] pathForResource:@"GameSettings" ofType:@"plist"];
    
    NSArray* objects = [NSArray arrayWithObjects: topScoreEasy,gameSpeed,difficulty,levelsCompleted,nil];
    NSArray* keys = [NSArray arrayWithObjects: @"topScoreEasy",@"gameSpeed", @"difficulty",@"levelsCompleted",nil];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
    //                                                               format:NSPropertyListXMLFormat_v1_0
     //                                                    errorDescription:&error];
    if(plistDict) {
        BOOL result = [plistDict writeToFile:plistPath atomically:YES];
        NSLog(@"result of write: %d",result);
    }
    else {
        NSLog(@"%@",error);
        [error release];
    }
    
}

@end
