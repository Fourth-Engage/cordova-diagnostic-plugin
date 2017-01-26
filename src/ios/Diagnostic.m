/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic.h"

@interface Diagnostic()

@end


@implementation Diagnostic


- (void)pluginInitialize {
    
    [super pluginInitialize];
    
    self.locationRequestCallbackId = nil;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

/********************************/
#pragma mark - Plugin API
/********************************/

#pragma mark - Location
- (void) isLocationAvailable: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[CLLocationManager locationServicesEnabled] && [self isLocationAuthorized] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[CLLocationManager locationServicesEnabled] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}


- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[self isLocationAuthorized] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    @try {
        NSString* status = [self getLocationAuthorizationStatusAsString:[CLLocationManager authorizationStatus]];
        NSLog(@"%@",[NSString stringWithFormat:@"Location authorization status is: %@", status]);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)])
        {
            BOOL always = [[command argumentAtIndex:0] boolValue];
            if(always){
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationAlwaysUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationAlwaysUsageDescription in its Info.plist");
                [self.locationManager requestAlwaysAuthorization];
                NSLog(@"Requesting location authorization: always");
            }else{
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationWhenInUseUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationWhenInUseUsageDescription in its Info.plist");
                [self.locationManager requestWhenInUseAuthorization];
                NSLog(@"Requesting location authorization: when in use");
            }
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
    self.locationRequestCallbackId = command.callbackId;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self sendPluginResult:pluginResult :command];
}

#pragma mark - Camera
- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[self isCameraPresent] && [self isCameraAuthorized] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isCameraPresent: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[self isCameraPresent] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command
{    @try {
    [self sendPluginResultBool:[self isCameraAuthorized] :command];
}
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    @try {
        NSString* status;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == AVAuthorizationStatusAuthorized){
            status = @"authorized";
        }
        NSLog(@"%@",[NSString stringWithFormat:@"Camera authorization status is: %@", status]);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self sendPluginResultBool:granted :command];
        }];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[[self getCameraRollAuthorizationStatus]  isEqual: @"authorized"] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    @try {
        NSString* status = [self getCameraRollAuthorizationStatus];
        NSLog(@"%@",[NSString stringWithFormat:@"Camera Roll authorization status is: %@", status]);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) requestCameraRollAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authStatus) {
            NSString* status = [self getCameraRollAuthorizationStatusAsString:authStatus];
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
        }];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

#pragma mark -  Wifi
- (void) isWifiAvailable: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[self connectedToWifi] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

#pragma mark -  Settings
- (void) switchToSettings: (CDVInvokedUrlCommand*)command
{
    @try {
        if (UIApplicationOpenSettingsURLString != nil ){
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] :command];
                    }else{
                        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] :command];
                    }
                }];
#endif
            }else{
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
                [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] :command];
            }
        }else{
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not supported below iOS 8"]:command];
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

#pragma mark - Audio
- (void) isMicrophoneAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
#ifdef __IPHONE_8_0
        AVAudioSessionRecordPermission recordPermission = [AVAudioSession sharedInstance].recordPermission;
        
        if(recordPermission == AVAudioSessionRecordPermissionGranted) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
        [self sendPluginResultBool:recordPermission == AVAudioSessionRecordPermissionGranted :command];
#else
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Only supported on iOS 8 and higher"]:command];
#endif
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    };
}

- (void) getMicrophoneAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    @try {
#ifdef __IPHONE_8_0
        NSString* status;
        AVAudioSessionRecordPermission recordPermission = [AVAudioSession sharedInstance].recordPermission;
        switch(recordPermission){
            case AVAudioSessionRecordPermissionDenied:
                status = @"denied";
                break;
            case AVAudioSessionRecordPermissionGranted:
                status = @"authorized";
                break;
            case AVAudioSessionRecordPermissionUndetermined:
                status = @"not_determined";
                break;
        }
        
        NSLog(@"%@",[NSString stringWithFormat:@"Microphone authorization status is: %@", status]);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
#else
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Only supported on iOS 8 and higher"]:command];
#endif
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) requestMicrophoneAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            NSLog(@"HAs access to microphone: %d", granted);
            [self sendPluginResultBool:granted :command];
        }];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

#pragma mark - Remote (Push) Notifications
- (void) isRemoteNotificationsEnabled: (CDVInvokedUrlCommand*)command
{
    @try {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // iOS 8+
            if(NSClassFromString(@"UNUserNotificationCenter")) {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                // iOS 10+
                UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    BOOL userSettingEnabled = settings.authorizationStatus == UNAuthorizationStatusAuthorized;
                    [self isRemoteNotificationsEnabledResult:userSettingEnabled:command];
                }];
#endif
            } else{
                // iOS 8 & 9
                UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
                BOOL userSettingEnabled = userNotificationSettings.types != UIUserNotificationTypeNone;
                [self isRemoteNotificationsEnabledResult:userSettingEnabled:command];
            }
        } else {
            // iOS7 and below
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
            UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
            BOOL isEnabled = enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
            [self sendPluginResultBool:isEnabled:command];
#endif
        }
        
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception:command];
    }
}
- (void) isRemoteNotificationsEnabledResult: (BOOL) userSettingEnabled : (CDVInvokedUrlCommand*)command
{
    // iOS 8+
    BOOL remoteNotificationsEnabled = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
    BOOL isEnabled = remoteNotificationsEnabled && userSettingEnabled;
    [self sendPluginResultBool:isEnabled:command];
}

- (void) getRemoteNotificationTypes: (CDVInvokedUrlCommand*)command
{
    @try {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // iOS 8+
            if(NSClassFromString(@"UNUserNotificationCenter")) {
                // iOS 10+
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    BOOL alertsEnabled = settings.alertSetting == UNNotificationSettingEnabled;
                    BOOL badgesEnabled = settings.badgeSetting == UNNotificationSettingEnabled;
                    BOOL soundsEnabled = settings.soundSetting == UNNotificationSettingEnabled;
                    BOOL noneEnabled = !alertsEnabled && !badgesEnabled && !soundsEnabled;
                    [self getRemoteNotificationTypesResult:command:noneEnabled:alertsEnabled:badgesEnabled:soundsEnabled];
                }];
#endif
            } else{
                // iOS 8 & 9
                UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
                BOOL noneEnabled = userNotificationSettings.types == UIUserNotificationTypeNone;
                BOOL alertsEnabled = userNotificationSettings.types & UIUserNotificationTypeAlert;
                BOOL badgesEnabled = userNotificationSettings.types & UIUserNotificationTypeBadge;
                BOOL soundsEnabled = userNotificationSettings.types & UIUserNotificationTypeSound;
                [self getRemoteNotificationTypesResult:command:noneEnabled:alertsEnabled:badgesEnabled:soundsEnabled];
            }
        } else {
            // iOS7 and below
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
            UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
            BOOL oneEnabled = enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone;
            BOOL alertsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeAlert;
            BOOL badgesEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeBadge;
            BOOL soundsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeSound;
            [self getRemoteNotificationTypesResult:command:noneEnabled:alertsEnabled:badgesEnabled:soundsEnabled];
#endif
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}
- (void) getRemoteNotificationTypesResult: (CDVInvokedUrlCommand*)command :(BOOL)noneEnabled :(BOOL)alertsEnabled :(BOOL)badgesEnabled :(BOOL)soundsEnabled
{
    // iOS 8+
    NSMutableDictionary* types = [[NSMutableDictionary alloc]init];
    if(alertsEnabled) {
        [types setValue:@"1" forKey:@"alert"];
    } else {
        [types setValue:@"0" forKey:@"alert"];
    }
    if(badgesEnabled) {
        [types setValue:@"1" forKey:@"badge"];
    } else {
        [types setValue:@"0" forKey:@"badge"];
    }
    if(soundsEnabled) {
        [types setValue:@"1" forKey:@"sound"];
    } else {;
        [types setValue:@"0" forKey:@"sound"];
    }
    [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self objectToJsonString:types]] :command];
}


- (void) isRegisteredForRemoteNotifications: (CDVInvokedUrlCommand*)command
{
    BOOL registered;
    @try {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // iOS8+
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
            registered = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
#endif
        } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
            // iOS7 and below
            UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
            registered = enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
#endif
        }
        [self sendPluginResultBool:registered :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

#pragma mark - Background refresh
- (void) getBackgroundRefreshStatus: (CDVInvokedUrlCommand*)command
{
    @try {
        NSString* status;
        
        if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
            status = @"authorized";
            NSLog(@"Background updates are available for the app.");
        }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
            status = @"denied";
            NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
        }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
            status = @"restricted";
            NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
        }
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

/********************************/
#pragma mark - Send results
/********************************/

- (void) sendPluginResult: (CDVPluginResult*)result :(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) sendPluginResultBool: (BOOL)result :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if(result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) handlePluginException: (NSException*) exception :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)jsCallback: (NSString*)jsString
{
    [self.commandDelegate evalJs:jsString];
}

/********************************/
#pragma mark - utility functions
/********************************/


- (NSString*) getLocationAuthorizationStatusAsString: (CLAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == kCLAuthorizationStatusNotDetermined){
        status = @"not_determined";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedAlways){
        status = @"authorized";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        status = @"authorized_when_in_use";
    }
    return status;
}

- (BOOL) isLocationAuthorized
{
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    if([status  isEqual: @"authorized"] || [status  isEqual: @"authorized_when_in_use"]) {
        return true;
    } else {
        return false;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)authStatus {
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    NSLog(@"%@",[NSString stringWithFormat:@"Location authorization status changed to: %@", status]);
    
    if(self.locationRequestCallbackId != nil){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.locationRequestCallbackId];
        self.locationRequestCallbackId = nil;
    }
    
    [self jsCallback:[NSString stringWithFormat:@"cordova.plugins.diagnostic._onLocationStateChange(\"%@\");", status]];
}

- (BOOL) isCameraPresent
{
    BOOL cameraAvailable =
    [UIImagePickerController
     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(cameraAvailable) {
        NSLog(@"Camera available");
        return true;
    }
    else {
        NSLog(@"Camera unavailable");
        return false;
    }
}

- (BOOL) isCameraAuthorized
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        return true;
    } else {
        return false;
    }
}

- (NSString*) getCameraRollAuthorizationStatus
{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    return [self getCameraRollAuthorizationStatusAsString:authStatus];
    
}

- (NSString*) getCameraRollAuthorizationStatusAsString: (PHAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == PHAuthorizationStatusNotDetermined ){
        status = @"not_determined";
    }else if(authStatus == PHAuthorizationStatusAuthorized){
        status = @"authorized";
    }
    return status;
}

- (BOOL) connectedToWifi  // Don't work on iOS Simulator, only in the device
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    
    if (getifaddrs(&addresses) != 0) {
        return NO;
    }
    
    cursor = addresses;
    while (cursor != NULL)  {
        if (cursor -> ifa_addr -> sa_family == AF_INET && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                
                NSLog(@"Wifi ON");
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    freeifaddrs(addresses);
    return wiFiAvailable;
}

- (NSString*) arrayToJsonString:(NSArray*)inputArray
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString*) objectToJsonString:(NSDictionary*)inputObject
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
