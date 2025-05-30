#import "AppPermissionsPlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@implementation AppPermissionsPlugin
{
    CBCentralManager *centralManager;
}

- (void)pluginInitialize {
    NSLog(@"Starting App Permissions plugin");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Initialize Bluetooth manager for permission checks
    centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @NO}];
}

- (void)requestLocationPermission:(CDVInvokedUrlCommand *)command {
    NSUInteger status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        self.command = command;
        [self.locationManager requestWhenInUseAuthorization];
        NSLog(@"requestWhenInUseAuthorization");
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSUInteger:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)requestBackgroundLocationPermission:(CDVInvokedUrlCommand *)command {
    NSUInteger status = [CLLocationManager authorizationStatus];
    if ((status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusNotDetermined ) && [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
        NSLog(@"requestAlwaysAuthorization");
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openURL:(CDVInvokedUrlCommand *)command {
    NSString* key = [command.arguments objectAtIndex:0];
    NSURL *url;
    if (key == (id)[NSNull null] || key.length == 0 ) {
        url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
    } else {
        url = [[NSURL alloc] initWithString:key];
    }
    [[UIApplication sharedApplication] openURL:url
                                       options:@{}
                             completionHandler:nil];
    NSLog(@"openURL: %@", url);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)checkLocationPermission:(CDVInvokedUrlCommand *)command {
    BOOL accessFineLocation = NO;
    BOOL accessCoarseLocation = NO;
    BOOL accessBackgroundLocation = NO;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // In iOS, we don't have separate fine and coarse permissions like in Android
    // Both are granted together with whenInUse or always authorization
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        accessFineLocation = YES;
        accessCoarseLocation = YES;
        
        // Check for background permission (always authorization)
        if (status == kCLAuthorizationStatusAuthorizedAlways) {
            accessBackgroundLocation = YES;
        }
    }
    
    // Create a response similar to the Android implementation
    NSDictionary *jsonObject = @{
        @"ACCESS_FINE_LOCATION": @(accessFineLocation),
        @"ACCESS_COARSE_LOCATION": @(accessCoarseLocation),
        @"ACCESS_BACKGROUND_LOCATION": @(accessBackgroundLocation)
    };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObject];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Authorization status: %d", status);
    if (self.command != nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSUInteger:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
        self.command = nil;
    }
}

- (void)shouldShowRequestPermissionRationale:(CDVInvokedUrlCommand *)command {
    // iOS doesn't have an equivalent to Android's shouldShowRequestPermissionRationale
    // But we can return a more useful response instead of "Not implemented"
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestNearbyDevicesPermission:(CDVInvokedUrlCommand *)command {
    // In iOS, Bluetooth permissions are implicitly requested when you start using CoreBluetooth
    // We'll initialize the central manager if it's not already initialized
    if (!centralManager) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @NO}];
    }
    
    // Return success as the permission will be requested when needed
    NSDictionary *response = @{
        @"status": @"requested",
        @"message": @"Permiso para dispositivos cercanos solicitado"
    };
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)checkNearbyDevicesPermission:(CDVInvokedUrlCommand *)command {
    NSString *permissionStatus = @"unknown";
    BOOL bluetoothPermission = NO;
    
    // Check Bluetooth authorization status
    if (@available(iOS 13.0, *)) {
        CBManagerAuthorization authStatus = [CBCentralManager authorization];
        
        switch (authStatus) {
            case CBManagerAuthorizationAllowedAlways:
                permissionStatus = @"granted";
                bluetoothPermission = YES;
                break;
            case CBManagerAuthorizationDenied:
                permissionStatus = @"denied";
                break;
            case CBManagerAuthorizationRestricted:
                permissionStatus = @"restricted";
                break;
            case CBManagerAuthorizationNotDetermined:
                permissionStatus = @"notDetermined";
                break;
            default:
                permissionStatus = @"unknown";
                break;
        }
    } else {
        // Before iOS 13, there was no explicit Bluetooth permission
        // We can only check if Bluetooth is powered on
        if (centralManager.state == CBManagerStatePoweredOn) {
            permissionStatus = @"granted";
            bluetoothPermission = YES;
        } else {
            permissionStatus = @"unknown";
        }
    }
    
    NSDictionary *jsonObject = @{
        @"BLUETOOTH_PERMISSION": @(bluetoothPermission),
        @"BLUETOOTH_STATUS": permissionStatus
    };
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObject];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
