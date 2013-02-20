//
//  ViewController.h
//  BatteryChart
//
//  Created by Nicolas Seriot on 2/13/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTChartView.h"
#import <MessageUI/MessageUI.h>

@class UIStatusBarServer;

@interface ViewController : UIViewController <BTChartViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) UIStatusBarServer *statusBarServer;
@property (nonatomic, retain) NSMutableArray *measures;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet BTChartView *chartView;

- (IBAction)addMeasure:(id)sender;
- (IBAction)emailMeasures:(id)sender;
- (IBAction)resetMeasures:(id)sender;

@end
