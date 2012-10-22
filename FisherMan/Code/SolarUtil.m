//
//  SolarUtil.m
//  Pick a Fish
//
//  Created by Khalid Al-Kooheji on 10/4/2012.
//  Copyright (c) 2012 kG Technologies. All rights reserved.
//

#import "SolarUtil.h"
#include "kazmath.h"
//reference : http://stackoverflow.com/questions/8708048/position-of-the-sun-given-time-of-day-latitude-and-longitude

@implementation SolarUtil

+ (NSUInteger) dayOfYear:(NSDate*) date
{
    NSCalendar *gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger result = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    //NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    [gregorian release];
    return result;
}



+ (CGPoint) sunPosition:(NSUInteger) dayOfYear year:(float) year hour:(float) hour lat:(float) lat lng:(float) lng
{
    //sunPosition = function(year, month, day, hour=12, min=0, sec=0,
     //                       lat=46.5, long=6.5) {
        
    const float twopi = 2 * kmPI;
    const float deg2rad = kmPI / 180;
    
// Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leap years
    

// Get Julian date - 2400000
    //float hour = ([components hour]) + ([components minute] / 60.0f) + [components second] / 3600.0f; // hour plus fraction
    float delta = year - 1949;
    int  leap = delta / 4; //# former leapyears
    float jd = (32916.5 + delta * 365) + leap + dayOfYear + (hour / 24.0f);
        
// The input to the Atronomer's almanach is the difference between
// the Julian date and JD 2451545.0 (noon, 1 January 2000)
    float   time = jd - 51545;
    
// Ecliptic coordinates
        
// Mean longitude
    float mnlong = 280.460 + 0.9856474f * time;
    mnlong = fmod(mnlong,360.0f);
    if (mnlong < 0)
        mnlong += 360.0f;
        
        
// Mean anomaly
    float   mnanom = 357.528f + 0.9856003f * time;
    mnanom = fmod(mnanom,360.0f);
    if (mnanom < 0)
        mnanom += 360.0f;
    mnanom = mnanom * deg2rad;
        
// Ecliptic longitude and obliquity of ecliptic
    float eclong = mnlong + 1.915f * sin(mnanom) + 0.020f * sin(2.0f * mnanom);
    eclong = fmod(eclong,360.0f);
    if (eclong < 0)
        eclong += 360.0f;
    
        
    float oblqec = 23.439f - 0.0000004f * time;
    eclong = eclong * deg2rad;
    oblqec = oblqec * deg2rad;
    
// Celestial coordinates
// Right ascension and declination
    float num = cos(oblqec) * sin(eclong);
    float den = cos(eclong);
    float ra = atan(num / den);
    if (den < 0)
        ra += kmPI;
    if (den >= 0 && num <0)
        ra += twopi;

    float dec = asin(sin(oblqec) * sin(eclong));
    
// Local coordinates
// Greenwich mean sidereal time
    float gmst = 6.697375f + 0.0657098242f * time + hour;
    gmst = fmod(gmst,24.0f);
    if (gmst < 0)
        gmst += 24;
    
// Local mean sidereal time
    float lmst = gmst + (lng / 15.0f);
    lmst = fmod(lmst,24);
    if (lmst < 0)
        lmst += 24;
    lmst = lmst * 15.0f * deg2rad;
    
// Hour angle
    float ha = lmst - ra;
    if (ha < -kmPI)
        ha += twopi;
    else if (ha > kmPI)
        ha -= twopi;
    

// Latitude to radians
    lat = lat * deg2rad;
    
// Azimuth and elevation
    float el = asin(sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha));
    float az = asin(-cos(dec) * sin(ha) / cos(el));
    
// For logic and names, see Spencer, J.W. 1989. Solar Energy. 42(4):353
    BOOL cosAzPos = (0 <= sin(dec) - sin(el) * sin(lat));
    BOOL sinAzNeg = (sin(az) < 0);
    if (cosAzPos && sinAzNeg)
        az += twopi;
    
        if (!cosAzPos)
            az = kmPI - az;
       
        
// if (0 < sin(dec) - sin(el) * sin(lat)) {
//     if(sin(az) < 0) az = az + twopi
// } else {
//     az = pi - az
// }
        
    //NSLog(@"sun pos - el:%3.05f\taz:%3.05f",el,az);
    //el = el / deg2rad;
    //az = az / deg2rad;
    //lat = lat / deg2rad;
    CGPoint p = {az,el};
        //return(list(elevation=el, azimuth=az))
    //}
    return p;
}

@end
