#import "AppPermissionsPlugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>

@implementation AppPermissionsPlugin

- (void)pluginInitialize {
    NSLog(@"Starting App Permissions plugin");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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
    if (@available(iOS 14.0, *)) {
        NSUInteger authorizationStatus = [self.locationManager  authorizationStatus];
        NSUInteger accuracyAuthorization = [self.locationManager accuracyAuthorization];
        NSDictionary *locationData = @{
            @"authorizationStatus": @(authorizationStatus),
            @"desiredAccuracy": @(accuracyAuthorization)
        };
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:locationData];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
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
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not implemented"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
