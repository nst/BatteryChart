//
//  Measure.m
//  MobileSignal
//
//  Created by Nicolas Seriot on 11/16/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import "BTMeasure.h"
#import "IOPowerSources.h"
#import "IOPSKeys.h"

static OSDBattery *osdBattery = nil;

@implementation BTMeasure

+ (OSDBattery *)osdBattery {
    if(osdBattery == nil) {
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/GAIA.framework"];
        BOOL success = [bundle load];
        NSAssert(success, @"-- cannot load GAIA framework");
        Class OSDBattery = NSClassFromString(@"OSDBattery");
        osdBattery = [OSDBattery sharedInstance];
        NSAssert(success, @"-- cannot get [OSDBattery sharedInstance]");
    }
    return osdBattery;
}

- (NSString *)description {
    NSString *dateString = [_date description];
    
    NSString *statusBarInfo = [NSString stringWithFormat:@"statusBarBatteryCapacity: %d\n statusBarBatteryState: %d\n statusBarBatteryDetailString: %@\n statusBarLevel: %d\n statusBarThermalColor: %d", _statusBarBatteryCapacity, _statusBarBatteryState, _statusBarBatteryDetailString, _statusBarLevel, _statusBarThermalColor];
    
    NSString *batteryInfo = [NSString stringWithFormat:@"currentCapacity: %d\n cycleCount: %d\n designCapacity: %d\n level: %d\n maxCapacity: %d\n rawVoltage: %d", _currentCapacity, _cycleCount, _designCapacity, _level, _maxCapacity, _rawVoltage];

    NSString *deviceInfo = [NSString stringWithFormat:@"deviceBatteryState: %d\n _deviceBatteryLevel: %f", _deviceBatteryState, _deviceBatteryLevel];

    NSString *ioKitInfo = [NSString stringWithFormat:@"ioKitLevel: %f", _ioKitLevel];

    return [@[dateString, statusBarInfo, batteryInfo, deviceInfo, ioKitInfo] componentsJoinedByString:@"\n\n"];
}

- (NSString *)csvDescription {
    return [NSString stringWithFormat:@"%@, %d, %d, %d, %d, %d, %d, %f", _date, _statusBarBatteryCapacity, _level, _deviceBatteryLevel >= 0.0 ? (int)(_deviceBatteryLevel * 100) : 0, _currentCapacity, _maxCapacity, _rawVoltage, _ioKitLevel];
}

- (void)dealloc {
	[_date release];
	[super dealloc];
}

+ (double)IOKitBatteryLevel {
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    
    CFDictionaryRef pSource = NULL;
    const void *psValue;
    
    int numOfSources = CFArrayGetCount(sources);
    if (numOfSources == 0) {
        NSLog(@"-- No power source found");
        return -1.0f;
    }
    
    for (int i = 0 ; i < numOfSources ; i++)
    {
        pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!pSource) {
            NSLog(@"-- Can't get power source description");
            return -1.0f;
        }
        psValue = (CFStringRef)CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));
        
        int curCapacity = 0;
        int maxCapacity = 0;
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);
        
        return ((double)curCapacity/(double)maxCapacity * 100.0f);
    }
    return -1.0f;
}

+ (BTMeasure *)measureWithStatusBarData:(StatusBarData *)statusBarData {
	
    BTMeasure *m = [[BTMeasure alloc] init];
    
    m.date = [NSDate date];
    
    m.statusBarBatteryCapacity = statusBarData->batteryCapacity;
    m.statusBarBatteryState = statusBarData->batteryState;
    m.statusBarBatteryDetailString = [NSString stringWithCString:statusBarData->batteryDetailString
                                                        encoding:NSUTF8StringEncoding];
    m.statusBarThermalColor = statusBarData->thermalColor;
    m.statusBarBatteryCapacity = statusBarData->batteryCapacity;
    
    OSDBattery *b = [self osdBattery];
    
    m.currentCapacity = [b _getBatteryCurrentCapacity];
    m.cycleCount = [b _getBatteryCycleCount];
    m.designCapacity = [b _getBatteryDesignCapacity];
    m.level = [b _getBatteryLevel];
    m.maxCapacity = [b _getBatteryMaxCapacity];
    m.rawVoltage = [b _getRawBatteryVoltage];
    
    m.deviceBatteryState = [[UIDevice currentDevice] batteryState];
    m.deviceBatteryLevel = [[UIDevice currentDevice] batteryLevel];
    
    m.ioKitLevel = [self IOKitBatteryLevel];
    
    return [m autorelease];
}

@end
