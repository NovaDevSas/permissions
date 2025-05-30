#import <Cordova/CDV.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppPermissionsPlugin : CDVPlugin <CLLocationManagerDelegate>
- (void)requestLocationPermission:(CDVInvokedUrlCommand*)command;
- (void)requestBackgroundLocationPermission:(CDVInvokedUrlCommand*)command;
- (void)checkLocationPermission:(CDVInvokedUrlCommand*)command;
- (void)openURL:(CDVInvokedUrlCommand*)command;
- (void)shouldShowRequestPermissionRationale:(CDVInvokedUrlCommand*)command;
- (void)requestNearbyDevicesPermission:(CDVInvokedUrlCommand*)command;
- (void)checkNearbyDevicesPermission:(CDVInvokedUrlCommand*)command;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CDVInvokedUrlCommand *command;

@end
