//
//  LCView.h
//  LightChart
//
//  Created by Nicolas Seriot on 11/19/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTMeasure;

@protocol BTChartViewDataSource
- (NSUInteger)numberOfMeasures;
- (BTMeasure *)measureAtIndex:(NSUInteger)index;
- (NSDate *)minDate;
- (NSDate *)maxDate;
@end

@interface BTChartView : UIView {
	IBOutlet NSObject <BTChartViewDataSource> *dataSource;
}

@property (nonatomic, retain) NSObject <BTChartViewDataSource> *dataSource;

@end
