//
//  Measure.h
//  MobileSignal
//
//  Created by Nicolas Seriot on 11/16/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct { // from UIStatusBarServerThread
    char itemIsEnabled[24];
    char timeString[64];
    int gsmSignalStrengthRaw;
    int gsmSignalStrengthBars;
    char serviceString[100];
    char serviceCrossfadeString[100];
    char serviceImages[2][100];
    char operatorDirectory[1024];
    unsigned int serviceContentType;
    int wifiSignalStrengthRaw;
    int wifiSignalStrengthBars;
    unsigned int dataNetworkType;
    int batteryCapacity;
    unsigned int batteryState;
    char batteryDetailString[150];
    int bluetoothBatteryCapacity;
    int thermalColor;
    unsigned int thermalSunlightMode : 1;
    unsigned int slowActivity : 1;
    unsigned int syncActivity : 1;
    char activityDisplayId[256];
    unsigned int bluetoothConnected : 1;
    unsigned int displayRawGSMSignal : 1;
    unsigned int displayRawWifiSignal : 1;
    unsigned int locationIconType : 1;
} StatusBarData;

@interface OSDBattery
+ (id)sharedInstance;
- (int)_getBatteryCurrentCapacity;
- (int)_getBatteryCycleCount;
- (int)_getBatteryDesignCapacity;
- (int)_getBatteryLevel;
- (int)_getBatteryMaxCapacity;
- (int)_getRawBatteryVoltage;
@end

@interface BTMeasure : NSObject {

}

@property (nonatomic, retain) NSDate *date;
@property int statusBarBatteryCapacity;
@property unsigned int statusBarBatteryState;
@property (nonatomic, retain) NSString *statusBarBatteryDetailString;
@property int statusBarLevel;
@property int statusBarThermalColor;

@property int currentCapacity;
@property int cycleCount;
@property int designCapacity;
@property int level;
@property int maxCapacity;
@property int rawVoltage;
@property double ioKitLevel;

@property UIDeviceBatteryState deviceBatteryState;
@property float deviceBatteryLevel;

+ (BTMeasure *)measureWithStatusBarData:(StatusBarData *)statusBarData;

- (NSString *)csvDescription;

@end
