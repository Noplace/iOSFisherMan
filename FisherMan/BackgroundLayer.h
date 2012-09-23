//
//  BackgroundLayer.h
//  FisherMan
//
//  Created by Khalid Al-Kooheji on 9/22/12.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface BackgroundLayer : CCLayer
{
    CGSize size;
    ccColor4F skyColor;
    float t;
}
@end
