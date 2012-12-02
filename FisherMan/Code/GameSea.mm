//
//  GameSea.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/9/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import "GameSea.h"


@interface GameSea()
{
    CCSpriteFrame *bombNormalFrame;
    CCSpriteFrame *bombRedFrame;
}
@end

@implementation GameSea

@synthesize model;
@synthesize seaObjectEventReceiverObject;

- (id) initWithModel:(GameModel*) gameModel;
{
    [super init];
    model = gameModel;
    [self initSeaAndFish];
    return self;
}

- (void) initSeaAndFish
{
    
    memset(model->waveTime_,0,sizeof(model->waveTime_));
    model->waveYTime_ = 0;
    
    // Define the buoyancy controller
    b2BuoyancyControllerDef bcd;
    
    bcd.normal.Set(0.0f, 1.0f);
    bcd.offset = ptm(40);
    bcd.density = 2.0f;
    bcd.linearDrag = 7.0f;
    bcd.angularDrag = 10.0f;
    bcd.useWorldGravity = true;
    
    model->seaBC = (b2BuoyancyController *)model->world->CreateController(&bcd);
	
    //model->seaObjectsParentNode = [CCSpriteBatchNode batchNodeWithFile:@"fish1.png" capacity:100];
    //model->seaObjectsTexture = [model->seaObjectsParentNode texture];
   
    model->seaObjectsParentNode = [CCSpriteBatchNode batchNodeWithFile:@"seaobjects.pvr.ccz"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"seaobjects.plist"];
    
    
    [model->seaLayer addChild:model->seaObjectsParentNode z:-3 tag:kTagParentNode];
	
    
    {
        
        //model->seaParentNode = [CCSpriteBatchNode batchNodeWithFile:@"sea-wave-deep.png" capacity:100];
        //CCTexture2D* seaTexture = [model->seaParentNode texture];
        model->seaShallowTexture = [[CCTextureCache sharedTextureCache] addImage:@"sea-wave-shallow.png"];
        model->seaDeepTexture = [[CCTextureCache sharedTextureCache] addImage:@"sea-wave-deep.png"];
        model->seaTexture = model->seaDeepTexture;
        
        for (int i=0;i<4;++i)
        {
            
            model->seaSprite[i] = [CCSprite spriteWithTexture:model->seaTexture rect:CGRectMake(0,0,model->winSize.width,model->seaTexture.contentSize.height)];
            ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
            model->seaSprite[i].anchorPoint = ccp(0,0);
            
            [model->seaSprite[i].texture setTexParameters:&tp];
            model->seaSprite[i].zOrder = -(i<<1);
            model->seaSprite[i].position = ccp(0,0);
            [model->seaLayer addChild:model->seaSprite[i]];
        }
        
        
    }
    [self setWaterType:1];
    
    
    //[self createFishingRod];
    
    bombNormalFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bomb.png"];
    bombRedFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bomb-red.png"];

    
}

- (void) setWaterType : (int) type
{
    static ccColor3B seaColors[4] = {
        ccc3(255, 255, 255),
        ccc3(200, 200, 200),
        ccc3(180, 180, 180),
        ccc3(140, 140, 140)
    };
    for (int i=0;i<4;++i)
    {
        model->seaSprite[i].texture = type == 0?model->seaShallowTexture:model->seaDeepTexture;
        model->seaSprite[i].color = seaColors[i];
        model->seaSprite[i].opacity = 225-(i*10);
      
        
       
    }
}


- (void) addNewSeaObject
{
	CCLOG(@"Add Sea Object");
	
    NSArray *images = [NSArray arrayWithObjects:@"fish1.png", @"fish2.png", @"fish3.png", @"fish4.png",@"bomb.png", nil];
    int objectIndex = rand() % 4;
    
    if (CCRANDOM_0_1() > 0.9f)
        objectIndex = 4;
    
    PhysicsSprite *sprite = [PhysicsSprite spriteWithSpriteFrameName:[images objectAtIndex:objectIndex]];
	[model->seaObjectsParentNode addChild:sprite z:-3 tag:kTagSeaObject];
	CGRect fishSize = CGRectMake(0, 0, sprite.contentSize.width,sprite.contentSize.height);
    
    if (objectIndex != 4)
        sprite.type = 0;
    else
        sprite.type = 1;//bomb;
    
    CGPoint p;
    p.x = CCRANDOM_0_1() * (model->winSize.width-fishSize.size.width);
    p.y = -100.0f;
 
	sprite.position = ccp(p.x,p.y);
	
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = model->world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(ptm(fishSize.size.width)*0.5f, ptm(fishSize.size.height)*0.5f);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
    body->SetUserData(sprite);
	body->CreateFixture(&fixtureDef);
    b2Vec2 force = b2Vec2(0,4900.0f);
    body->ApplyForceToCenter(force);
	model->seaBC->AddBody(body);
    sprite.timeAlive = 0;
	[sprite setPhysicsBody:body];
}





- (void) updateSea: (ccTime) dt
{
    static const CGFloat pos[4]={-10,20,30,50};
    static const CGFloat amp[4] = {10,12,20,26};
    //static const CGFloat dir[4] = {1,1,1,1};
    static const CGFloat freq[4] = {1.0f,0.7f,0.5f,0.3f};
    static const CGFloat phase[4] = {kmPI*0.25f,0,kmPI,0};
    const float freqY = 0.2f;
    float dispX = model->windIntensity*0.5f*(model->winSize.width)/4;
    float rangeX = dispX/2;
    
    static float lastx[4] = {0,0,0,0};
    float dx=0;
    float cy = (model->seaTexture.contentSize.height*0.5f);
    for (int i=0;i<4;++i)
    {
        float freqX = freq[i];
        float ampY = amp[i]*model->windIntensity;
        lastx[i] = model->seaSprite[i].position.x;
        //seaSprite[i].position = ccp(dispX+dir[i]*(sin((2*kmPI*waveTime_[i]*freqX)+phase[i])*rangeX),pos[i]+sin(2*kmPI*waveYTime_*freqY)*ampY);
        float waveIntensity = 1;
        float u = sin((2*kmPI*model->waveTime_[i]*freqX)+phase[i])*rangeX;
        CGRect texrect = CGRectMake(u,0, model->seaTexture.contentSize.width+waveIntensity, model->seaTexture.contentSize.height);
        

        model->seaSprite[i].position = dccp(model->seaSprite[i].position.x,pos[i]+sin(2*kmPI*model->waveYTime_*freqY)*ampY);
        [model->seaSprite[i] setTextureCoords:texrect];
        
        
        dx += model->seaSprite[i].position.x - lastx[i];
        model->waveTime_[i] += dt*0.2f;
        model->waveYTime_ += dt*0.2f;
        if (model->waveTime_[i] >= (1/freqX))
        {
            model->waveTime_[i] -= (1/freqX);
        }
        if (model->waveYTime_ >= (1/freqY) )
            model->waveYTime_ -= (1/freqY);
    }
    
    model->seaBC->offset = ptm(model->seaSprite[2].position.y+model->seaTexture.contentSize.height*0.5f);
    
   
    /*dx = seaSprite[2].position.x - lastx[2];
     b2Vec2 force = b2Vec2(dx*100/rangeX,0);
     
     b2Body* body = world->GetBodyList();
     
     while (body != NULL)
     {
     body->ApplyForceToCenter(force);
     body = body->GetNext();
     }*/
    
    
}


- (void) updateFish: (ccTime) dt
{
    
    
    if (model->startCatchSeaObject == YES)
    {
        model->catchingTimer.percentage = ((model->catchSeaObjectTime-model->catchSeaObjectCounter) / model->catchSeaObjectTime)*100.0;
    }
    
    if (model->catchSeaObjectCounter <= 0 && model->startCatchSeaObject == YES && model->currentSeaObjectBeingCaught != NULL)
    {
        NSLog(@"Caught Object");
        [seaObjectEventReceiverObject didCatchObject:model->currentSeaObjectBeingCaught];
        
    }
    
    if (model->seaObjectSpawnCounter <= 0)
    {
        model->seaObjectSpawnCounter = model->seaObjectSpawnTime;
        [self addNewSeaObject];
    }
    
    //fish
    for (int i=0;i<[model->seaObjectsParentNode.children count];++i)
    {
        PhysicsSprite* sp = [model->seaObjectsParentNode.children objectAtIndex:i];
        if (sp.tag == kTagSeaObject)// && !(model->currentSeaObjectBeingCaught != NULL && model->currentSeaObjectBeingCaught == sp->body_))
        {
            
            if (sp.type == 1) //bomb
            {
                float f = sin(sp.timeAlive*sp.timeAlive*kmPI);
                if (f > 0.9f)
                    [sp setDisplayFrame:bombRedFrame];
                else if (f < -0.9f)
                   [sp setDisplayFrame:bombNormalFrame];
                //sp.scale = 1.0f +                 //sp.color = colorLerp3B(ccc3(255, 255, 255), ccc3(255, 0, 0), 1+sin(sp.timeAlive*kmPI));
            }
            
            sp.timeAlive += dt;
            if (sp.type == 0)
            {
                if (sp.timeAlive >= model->fishAliveTime)
                {
                    if (model->currentSeaObjectBeingCaught != NULL && model->currentSeaObjectBeingCaught == sp->body_)
                    {
                        [seaObjectEventReceiverObject stopCatching];
                    }
                    sp->body_->ApplyForceToCenter(b2Vec2(0,-500.0f));
                }
                if (sp.timeAlive > model->fishAliveTime+1.0f)
                {
                    model->world->DestroyBody(sp->body_);
                    [model->seaObjectsParentNode removeChild:sp cleanup:YES];
                    ++([GameManager sharedGameManager]->counters.fishMissed);
                }
            }
            else if (sp.type == 1) //bomb
            {
                if (sp.timeAlive >= model->bombAliveTime)
                {
                    if (model->currentSeaObjectBeingCaught != NULL && model->currentSeaObjectBeingCaught == sp->body_)
                    {
                        [seaObjectEventReceiverObject stopCatching];
                    }
                    [seaObjectEventReceiverObject bombExplode:sp->body_];
                    model->world->DestroyBody(sp->body_);
                    [model->seaObjectsParentNode removeChild:sp cleanup:YES];
                    
                   
                }
            }
        }
        
    }
    
    
    model->seaObjectSpawnCounter -= dt;
    model->catchSeaObjectCounter -= dt;
}

- (void) update: (ccTime) dt
{
    [self updateSea:dt];
    [self updateFish:dt];
}



@end
