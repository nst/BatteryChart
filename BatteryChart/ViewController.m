//
//  ViewController.m
//  BatteryChart
//
//  Created by Nicolas Seriot on 2/13/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "ViewController.h"
#import "BTMeasure.h"
#import "UIStatusBarServer.h"

@interface ViewController ()

@end

static NSString *measuresFilePath = nil; // new path each time the application is started again

@implementation ViewController

- (void)dealloc {
    [_statusBarServer release];
    [_measures release];
    [_textView release];
    [_chartView release];
    [super dealloc];
}

- (void)batteryStatusDidChange:(NSNotification *)notification {
    NSLog(@"-- %@ %@", notification.name, notification.userInfo);
    
    [self measureBattery];
}

- (NSString *)measuresFilePath {
    if(measuresFilePath == nil) {
        NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = [NSString stringWithFormat:@"%d.csv", (int)[[NSDate date] timeIntervalSince1970]];
        NSString *filePath = [documentdir stringByAppendingPathComponent:fileName];
        measuresFilePath = [filePath retain];
    }
    return measuresFilePath;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
	StatusBarData *statusBarData = (StatusBarData *)[UIStatusBarServer getStatusBarData];
    BTMeasure *m = [BTMeasure measureWithStatusBarData:statusBarData];
	m.currentCapacity = 0; // store 0 capacity for the time the application is suspended
	[self didReceiveMeasure:m];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self measureBattery];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [[UIScreen mainScreen] setBrightness:1.0];

    [UIApplication sharedApplication].idleTimerDisabled = YES; // prevent sleep

    self.measures = [NSMutableArray array];
    
    [self startListeningToStatusBarServer];
    
    _chartView.dataSource = self;

    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    NSString *path = [self measuresFilePath];
    NSError *error = nil;
    BOOL success = [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(success == NO) {
        NSLog(@"-- cannot create measures files %@", error);
        return;
    }
}

- (void)writeMeasureToFile:(BTMeasure *)m {
    
    NSString *csvLine = [[m csvDescription] stringByAppendingString:@"\n"];
    NSData *csvData = [csvLine dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *path = [self measuresFilePath];
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fh seekToEndOfFile];
    [fh writeData:csvData];
    [fh closeFile];
}

- (void)measureBattery {
	StatusBarData *statusBarData = (StatusBarData *)[UIStatusBarServer getStatusBarData];
    [self addMeasureFromStatusBarServerData:statusBarData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveMeasure:(BTMeasure *)m {
	
    [_measures addObject:m];
	
    NSLog(@"-- %@", m);
    
    _textView.text = [NSString stringWithFormat:@"%d measures\n\n%@", [_measures count], [m description]];
    
    [self writeMeasureToFile:m];
    
	[_chartView setNeedsDisplay];
}

- (void)addMeasureFromStatusBarServerData:(StatusBarData *)statusBarData {	
	BTMeasure *m = [BTMeasure measureWithStatusBarData:statusBarData];
	
	[self didReceiveMeasure:m];
}

- (void)stopListeningToStatusBarServer {
	self.statusBarServer.statusBar = nil;
	self.statusBarServer = nil;
}

- (void)startListeningToStatusBarServer {
	[self stopListeningToStatusBarServer];
	self.statusBarServer = [[[UIStatusBarServer alloc] initWithStatusBar:self] autorelease];
	
	StatusBarData *statusBarData = (StatusBarData *)[UIStatusBarServer getStatusBarData];
	[self addMeasureFromStatusBarServerData:statusBarData];
}

- (IBAction)addMeasure:(id)sender {
    [self measureBattery];
}

- (IBAction)emailMeasures:(id)sender {

    NSString *path = [self measuresFilePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(data == nil) return;

    if([MFMailComposeViewController canSendMail] == NO) return;
    
    MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
        
    [mailVC addAttachmentData:data mimeType:@"text/csv" fileName:[[path componentsSeparatedByString:@"/"] lastObject]];
    
    mailVC.mailComposeDelegate = self;
    [mailVC setSubject:@"BatteryChart Measures"];
    
    [self presentViewController:mailVC animated:YES completion:^{
        
    }];
}

- (IBAction)resetMeasures:(id)sender {
    [self.measures removeAllObjects];
    
    _textView.text = @"";
    
    [_chartView setNeedsDisplay];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark MSChartViewDataSource

- (NSUInteger)numberOfMeasures {
	return [_measures count];
}

- (BTMeasure *)measureAtIndex:(NSUInteger)index {
	if(index >= [_measures count]) return nil;
	
	return [_measures objectAtIndex:index];
}

- (NSDate *)minDate {
	if([_measures count] == 0) return nil;
	
	BTMeasure *m = [_measures objectAtIndex:0];
	return m.date;
}

- (NSDate *)maxDate {
	BTMeasure *m = [_measures lastObject];
	return m.date;
}

#pragma mark UIStatusBarServerDelegate

- (void)statusBarServer:(id)arg1 didReceiveStatusBarData:(StatusBarData *)statusBarData withActions:(NSInteger)arg3 {
	NSLog(@"-- statusBarServer:didReceiveStatusBarData:withActions:");
    
    [self addMeasureFromStatusBarServerData:statusBarData];
}

- (void)statusBarServer:(id)arg1 didReceiveStyleOverrides:(NSInteger)arg2 {
	NSLog(@"-- statusBarServer:didReceiveStyleOverrides:");
}

- (void)statusBarServer:(id)arg1 didReceiveGlowAnimationState:(BOOL)arg2 forStyle:(NSInteger)arg3 {
	NSLog(@"-- statusBarServer:didReceiveGlowAnimationState:");
}

- (void)statusBarServer:(id)arg1 didReceiveDoubleHeightStatusString:(id)arg2 forStyle:(NSInteger)arg3 {
	NSLog(@"-- statusBarServer:didReceiveDoubleHeightStatusString:");
}

#pragma mark rotation

- (BOOL)shouldAutorotate {
    return NO;
}

@end
