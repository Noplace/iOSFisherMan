//
//  SeaHelper.h
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/7/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#ifndef Pick_a_Fish_SeaHelper_h
#define Pick_a_Fish_SeaHelper_h


class FishCollideCallback : public b2QueryCallback
{
public:
    b2Vec2 pointToTest;
    b2Fixture * fixtureFound;
    FishCollideCallback(const b2Vec2& point) {
        pointToTest = point;
        fixtureFound = NULL;
    }
    bool ReportFixture(b2Fixture* fixture) {
        b2Body* body = fixture->GetBody();
        PhysicsSprite* sp = (PhysicsSprite*)body->GetUserData();
        
        if (body->GetType() == b2_dynamicBody && sp.tag == kTagSeaObject) {
            if (fixture->TestPoint(pointToTest)) {
                fixtureFound = fixture;
                return false;
            } }
        return true;
    }
};

#endif
