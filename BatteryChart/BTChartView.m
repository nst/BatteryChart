//
//  LCView.m
//  LightChart
//
//  Created by Nicolas Seriot on 11/19/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import "BTChartView.h"
#import "BTMeasure.h"

@implementation BTChartView

@synthesize dataSource;

- (CGPoint)pointForMeasure:(BTMeasure *)m {
	CGFloat height = [self bounds].size.height;
	CGFloat width = [self bounds].size.width;
	
	NSDate *minDate = [dataSource minDate];
	NSDate *maxDate = [NSDate date];

	double percentX = 0.0;
    
	if(minDate != maxDate) { // just another way to say "if i > 0"
		NSTimeInterval minDateTimeInterval = [minDate timeIntervalSinceReferenceDate];
		NSTimeInterval maxDateTimeInterval = [maxDate timeIntervalSinceReferenceDate];
		
		NSTimeInterval range = maxDateTimeInterval - minDateTimeInterval;
		
		percentX = ([m.date timeIntervalSinceReferenceDate] - minDateTimeInterval) / range;
	}

    double percentY = (double)(m.currentCapacity) / m.maxCapacity;
    
	double x = width * percentX;
	double y = height - (percentY * height);
    
	CGPoint p = CGPointMake(x, y);
	
	return p;
}

- (void)fillAndStrikePath:(UIBezierPath *)path batteryState:(UIDeviceBatteryState)batteryState {
    
	UIColor *stokeColor = [UIColor blackColor];
    UIColor *fillColor = [UIColor whiteColor]; // UIDeviceBatteryStateUnknown
    if(batteryState == UIDeviceBatteryStateUnplugged) fillColor = [UIColor orangeColor]; // on battery, discharging
    if(batteryState == UIDeviceBatteryStateCharging) fillColor = [UIColor yellowColor]; // plugged in, less than 100%
    if(batteryState == UIDeviceBatteryStateFull) fillColor = [UIColor greenColor]; // plugged in, at 100%

	[stokeColor setStroke];
	[fillColor setFill];
	
	[path fill];
	[path stroke];
}

- (UIBezierPath *)horizontalScalesPath:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSUInteger nbSteps = 10;
        
    for(NSUInteger i = 0; i < nbSteps; i++) {
        CGFloat y = rect.size.height * (double)i / nbSteps;
        [path moveToPoint:CGPointMake(0.0, y)];
        [path addLineToPoint:CGPointMake(rect.size.width, y)];
    }
    
    return path;
}

- (void)drawRect:(CGRect)rect {

    UIBezierPath *scalesPath = [self horizontalScalesPath:rect];
    UIColor *stokeColor = [UIColor lightGrayColor];
	[stokeColor setStroke];
	[scalesPath stroke];
    
	if([dataSource numberOfMeasures] == 0) return;

	UIBezierPath *path = nil;
	
	// first point
	
	BTMeasure *m = [dataSource measureAtIndex:0];
	BTMeasure *previousMeasure = nil;
	
	CGPoint p0 = [self pointForMeasure:m];
	CGPoint openingPoint = p0;
	
	[path moveToPoint:p0];
		
	CGPoint p = CGPointZero;
	CGPoint previousPoint = CGPointZero;
	
	for(NSUInteger i = 0; i < [dataSource numberOfMeasures]; i++) {		
		
		if (i > 0) previousMeasure = m;
		m = [dataSource measureAtIndex:i];
        
        //NSLog(@"-- previous %@ (%d) [%d], now *%d* %@ (%d) [%d]", previousMeasure.date, previousMeasure.level, [previousMeasure deviceIsPlugged], i, m.date, m.level, [m deviceIsPlugged]);

		if (i > 0) previousPoint = p;
		p = [self pointForMeasure:m];
		
        //NSLog(@"   last point y %f previous %f", p.y, previousPoint.y);
        
		BOOL hasSameLevel = m.level == previousMeasure.level;
		BOOL hasSameState = m.statusBarBatteryState == previousMeasure.statusBarBatteryState;
		BOOL isLastPoint = i == ([dataSource numberOfMeasures] - 1);
		
		if(i == 0) {
			// open path
			path = [UIBezierPath bezierPath];
			[path moveToPoint:p];
			openingPoint = p;
		}
		
		if (hasSameLevel && hasSameState) {
			// just add line
			[path addLineToPoint:CGPointMake(p.x, previousPoint.y)];
			[path addLineToPoint:CGPointMake(p.x, p.y)];
		} else {
			// close previous, open new one
			if(i > 0) {
				[path addLineToPoint:CGPointMake(p.x, previousPoint.y)];
			}
			[path addLineToPoint:CGPointMake(p.x, self.bounds.size.height)];
			[path addLineToPoint:CGPointMake(openingPoint.x, self.bounds.size.height)];
			[path addLineToPoint:openingPoint];

			[self fillAndStrikePath:path batteryState:previousMeasure.deviceBatteryState];
			
			path = [UIBezierPath bezierPath];
			[path moveToPoint:p];
			openingPoint = p;
		}
		
		if (isLastPoint) {
			// add a temporary "guessed" measure for current date
			BTMeasure *tmpMeasure = [[[BTMeasure alloc] init] autorelease];
            tmpMeasure.currentCapacity = m.currentCapacity;
            tmpMeasure.maxCapacity = m.maxCapacity;
            tmpMeasure.statusBarBatteryState = m.statusBarBatteryState;
            tmpMeasure.deviceBatteryState = m.deviceBatteryState;
			tmpMeasure.date = [NSDate date];
			CGPoint tmpPoint = [self pointForMeasure:tmpMeasure];

			// close
			[path addLineToPoint:CGPointMake(tmpPoint.x, p.y)];
			[path addLineToPoint:CGPointMake(tmpPoint.x, self.bounds.size.height)];
			[path addLineToPoint:CGPointMake(openingPoint.x, self.bounds.size.height)];
			[path addLineToPoint:openingPoint];

			[self fillAndStrikePath:path batteryState:m.deviceBatteryState];
		}
		
	}
}

- (void)dealloc {
	[dataSource release];
    [super dealloc];
}

@end
