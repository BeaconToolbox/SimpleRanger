//
//  ViewController.m
//  SimpleRanger
//
//  Created by George Villasboas on 11/13/13.
//  Copyright (c) 2014 BeaconToolbox - Logics Software. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <sys/sysctl.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *_locationManager;
@property (strong, nonatomic) CLBeaconRegion *_clRegion;

@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;

@end

@implementation ViewController

#pragma mark -
#pragma mark Getters overriders
#pragma mark -

#pragma mark -
#pragma mark Setters overriders
#pragma mark -

#pragma mark -
#pragma mark Designated initializers
#pragma mark -

#pragma mark -
#pragma mark Public methods
#pragma mark -

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (NSString *)device
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
}

- (NSString *)osVersion
{
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    u_int namelen = sizeof(mib) / sizeof(mib[0]);
    size_t bufferSize = 0;
    
    NSString *osBuildVersion = nil;
    
    // Get the size for the buffer
    sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
    
    u_char buildBuffer[bufferSize];
    int result = sysctl(mib, namelen, buildBuffer, &bufferSize, NULL, 0);
    
    if (result >= 0) {
        osBuildVersion = [[NSString alloc] initWithBytes:buildBuffer length:bufferSize encoding:NSUTF8StringEncoding];
    }
    
    return [NSString stringWithFormat:@"%@ (%@)", [[UIDevice currentDevice] systemVersion], osBuildVersion];
}

- (void)turnON
{
    NSUUID *regionUUID = [[NSUUID alloc] initWithUUIDString:@"359E7924-DF9F-43DD-98DE-8A74409627FD"];
    self._clRegion = [[CLBeaconRegion alloc] initWithProximityUUID:regionUUID identifier:regionUUID.UUIDString];
    self._clRegion.notifyEntryStateOnDisplay = NO;
    self._clRegion.notifyOnEntry = NO;
    self._clRegion.notifyOnExit = NO;
    [self._locationManager startRangingBeaconsInRegion:self._clRegion];
}

- (void)turnOFF
{
    [self._locationManager stopRangingBeaconsInRegion:self._clRegion];
    self.view.backgroundColor = [UIColor redColor];
    self.accuracyLabel.text = @"";
}

#pragma mark -
#pragma mark ViewController life cycle
#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self._locationManager = [[CLLocationManager alloc] init];
    self._locationManager.delegate = self;
    
    self.view.backgroundColor = [UIColor redColor];
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@\niOS %@", [self device], [self osVersion]];
    
    self.accuracyLabel.text = @"";
    
    [self turnON];
    
}

#pragma mark -
#pragma mark Overriden methods
#pragma mark -

#pragma mark -
#pragma mark Storyboards Segues
#pragma mark -

#pragma mark -
#pragma mark Target/Actions
#pragma mark -

- (IBAction)monitor:(UISwitch *)sender
{
    if (sender.on) [self turnON];
    else [self turnOFF];
}

#pragma mark -
#pragma mark Delegates
#pragma mark -

#pragma mark CLLocationManager Delegates

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *beacon = beacons[0];
        self.view.backgroundColor = [UIColor greenColor];
        self.accuracyLabel.hidden = NO;
        self.accuracyLabel.text = [NSString stringWithFormat:@"%.2f", beacon.accuracy];
        
        NSLog(@"%@", beacon);
    }
    else{
        self.view.backgroundColor = [UIColor redColor];
        self.accuracyLabel.hidden = YES;
    }
    
}

#pragma mark -
#pragma mark Notification center
#pragma mark -

@end
