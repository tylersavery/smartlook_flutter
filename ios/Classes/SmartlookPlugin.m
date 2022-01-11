#import "SmartlookPlugin.h"
#import <WebKit/WebKit.h>
#import "Smartlook.h"

#ifdef DEBUG
//#   define DLog(fmt, ...) NSLog((@"👀Smartlook: [Line %d] " fmt), __LINE__, ##__VA_ARGS__);
#   define DLog(...)
#else
#   define DLog(...)
#endif

#define CALL_METHOD_IS(methodName) [call.method isEqualToString:@methodName]

#define IS_STRING_WITH_VALUE(string) ([string isKindOfClass:[NSString class]] && string > 0)
#define BOOL_VALUE_OR_DEFAULT(value,dft) ([value respondsToSelector:@selector(boolValue)] ? [value boolValue] : dft)
#define INT_VALUE_OR_DEFAULT(value,dft) ([value respondsToSelector:@selector(integerValue)] ? [value integerValue] : dft)

@interface SmartlookEventHandler: NSObject<FlutterStreamHandler>

@property (strong, nonatomic) FlutterEventSink eventSink;

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events;

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments;

@end

@implementation SmartlookEventHandler

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if (self.eventSink == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dashboardURLDidChange:) name:SLDashboardSessionURLChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dashboardURLDidChange:) name:SLDashboardVisitorURLChangedNotification object:nil];
        self.eventSink = events;
    }
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if (self.eventSink != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SLDashboardSessionURLChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SLDashboardVisitorURLChangedNotification object:nil];
        self.eventSink = nil;
    }
    return nil;
}

- (void)dashboardURLDidChange:(NSNotification *)notification {
    if (self.eventSink != nil) {
        if ([notification.name isEqualToString:SLDashboardSessionURLChangedNotification]) {
            self.eventSink([Smartlook getDashboardSessionURLWithCurrentTimestamp:NO].absoluteString);
        } else if ([notification.name isEqualToString:SLDashboardVisitorURLChangedNotification]) {
            self.eventSink([Smartlook getDashboardVisitorURL].absoluteString);
        }
    }
}

@end

@implementation SmartlookPlugin

SmartlookEventHandler *eventHandler;

NSDictionary<NSString*,NSString*> *flutterEventTrackingModeToNative;
NSDictionary<NSString*,NSString*> *nativeEventTrackingModeToFlutter;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"smartlook"
                                     binaryMessenger:[registrar messenger]];
    SmartlookPlugin* instance = [[SmartlookPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:@"smartlookEvent" binaryMessenger:registrar.messenger];
    eventHandler = [SmartlookEventHandler new];
    [eventChannel setStreamHandler:eventHandler];
    
    flutterEventTrackingModeToNative = @{
        @"FULL_TRACKING"                 : SLEventTrackingModeFullTracking,
        @"IGNORE_USER_INTERACTION"       : SLEventTrackingModeIgnoreUserInteractionEvents,
        @"IGNORE_NAVIGATION_INTERACTION" : SLEventTrackingModeIgnoreNavigationInteractionEvents,
        @"IGNORE_RAGE_CLICKS"            : SLEventTrackingModeIgnoreRageClickEvents,
        @"NO_TRACKING"                   : SLEventTrackingModeNoTracking
    };
    nativeEventTrackingModeToFlutter = @{
        SLEventTrackingModeFullTracking                      : @"FULL_TRACKING",
        SLEventTrackingModeIgnoreUserInteractionEvents       : @"IGNORE_USER_INTERACTION",
        SLEventTrackingModeIgnoreNavigationInteractionEvents : @"IGNORE_NAVIGATION_INTERACTION",
        SLEventTrackingModeIgnoreRageClickEvents             : @"IGNORE_RAGE_CLICKS",
        SLEventTrackingModeNoTracking                        : @"NO_TRACKING"
    };
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _internal_handleMethodCall:call result:result];
    });
}

- (void)setupSmartlook:(id)flutterOptions {
    
    DLog(@"options = '%@'", flutterOptions);
    
    NSDictionary *options;
    
    if ([flutterOptions isKindOfClass:[NSString class]]) {
        NSError *e;
        options = [NSJSONSerialization JSONObjectWithData:[flutterOptions dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&e];
        if (e != nil || ![options isKindOfClass:[NSDictionary class]] ) {
            return;
        }
    }

    SLSetupConfiguration *setupConfiguration = [[SLSetupConfiguration alloc] initWithKey:[options valueForKey:@"ApiKey"]];
    setupConfiguration.enableAdaptiveFramerate = NO;

    id fps = [options valueForKey:@"Fps"];
    if ([fps respondsToSelector:@selector(integerValue)]) {
        setupConfiguration.framerate = [fps integerValue];
    }

    id startNewSession = [options valueForKey:@"StartNewSession"];
    if ([startNewSession respondsToSelector:@selector(boolValue)]) {
        setupConfiguration.resetSession = [startNewSession boolValue];
    }

    id startNewSessionAndUser = [options valueForKey:@"StartNewSessionAndUser"];
    if ([startNewSessionAndUser respondsToSelector:@selector(boolValue)]) {
        setupConfiguration.resetSessionAndUser = [startNewSessionAndUser boolValue];
    }

    [setupConfiguration setInternalProps:@{@"sdkFramework" : @"FLUTTER"}];
    
    [Smartlook setupWithConfiguration:setupConfiguration];
}

- (void)_internal_handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    DLog(@"Smartlook: flutter log:\nmethod: %@,\nstart args: %@", call.method, [call.arguments description]);
    
    // MARK: Setup
    if (CALL_METHOD_IS("setupBridge")) {
        DLog(@"-> %@", call.method);
        [self setupSmartlook:call.arguments[@"options"]];
        return;
    }
        
    if (CALL_METHOD_IS("setupAndStartRecordingBridge")) {
        DLog(@"-> %@", call.method);
        [self setupSmartlook:call.arguments[@"options"]];
        [Smartlook startRecording];
        return;
    }
    
    if (CALL_METHOD_IS("setUserIdentifier")) {
        DLog(@"-> %@", call.method);
        NSString *userIdentifier = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(userIdentifier)) {
            [Smartlook setUserIdentifier:userIdentifier];
        }
        NSDictionary *map = call.arguments[@"map"];
        if ([map respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
            [map enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, id _Nonnull value, BOOL * _Nonnull stop) {
                [Smartlook setSessionPropertyValue:value forName:name];
            }];
        }
        return;
    }
    
    if (CALL_METHOD_IS("resetSession")) {
        DLog(@"-> %@", call.method);
        NSNumber *resetUser = call.arguments[@"resetUser"];
        [Smartlook resetSessionAndUser:[resetUser boolValue]];
        return;
    }
    
    // MARK: Recording
    if (CALL_METHOD_IS("startRecording")) {
        DLog(@"-> %@", call.method);
        [Smartlook startRecording];
        return;
    }
    if (CALL_METHOD_IS("stopRecording")) {
        DLog(@"-> %@", call.method);
        [Smartlook stopRecording];
        return;
    }
    if (CALL_METHOD_IS("isRecording")) {
        DLog(@"-> %@", call.method);
        result([NSNumber numberWithBool:[Smartlook isRecording]]);
        return;
    }
    
    
    // MARK: Timed Events
    if (CALL_METHOD_IS("startTimedCustomEvent")) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        NSDictionary *map = call.arguments[@"map"];
        if (IS_STRING_WITH_VALUE(key)) {
            NSUUID *identifier = [Smartlook startTimedCustomEventWithName:key props:map];
            result([identifier UUIDString]);
        }
        return;
    }
    
    if (CALL_METHOD_IS("stopTimedCustomEvent")) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        NSDictionary *map = call.arguments[@"map"];
        if (IS_STRING_WITH_VALUE(key)) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:key];
            if (uuid != nil) {
                [Smartlook trackTimedCustomEventWithEventId:uuid props:map];
            }
        }
        return;
    }
    
    if (CALL_METHOD_IS("cancelTimedCustomEvent")) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        NSString *reason = call.arguments[@"reason"];
        NSDictionary *map = call.arguments[@"map"];
        if (IS_STRING_WITH_VALUE(key)) {
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:key];
            if (uuid != nil) {
                [Smartlook trackTimedCustomEventCancelWithEventId:uuid reason:reason props:map];
            }
        }
        return;
    }
    
    
    // MARK: Custom events
    if (CALL_METHOD_IS("trackCustomEvent")) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        NSDictionary *map = call.arguments[@"map"];
        if (IS_STRING_WITH_VALUE(key)) {
            [Smartlook trackCustomEventWithName:key props:map];
        }
        return;
    }
    
    
    if (CALL_METHOD_IS("trackNavigationEvent")) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(key)) {
            SLNavigationType navType = INT_VALUE_OR_DEFAULT(call.arguments[@"type"], 0) == 1 ? SLNavigationTypeExit : SLNavigationTypeEnter;
            [Smartlook trackNavigationEventWithControllerId:key type:navType];
        }
        return;
    }
    
    
    // MARK: Sensitive
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (CALL_METHOD_IS("startFullscreenSensitiveMode")) {
        DLog(@"-> %@", call.method);
        [Smartlook beginFullscreenSensitiveMode];
        return;
    }
    if (CALL_METHOD_IS("stopFullscreenSensitiveMode")) {
        DLog(@"-> %@", call.method);
        [Smartlook endFullscreenSensitiveMode];
        return;
    }
    if ([@"isFullscreenSensitiveModeActive" isEqualToString:call.method]) {
        DLog(@"-> %@", call.method);
        result([NSNumber numberWithBool:[Smartlook isFullscreenSensitiveModeActive]]);
        return;
    }
#pragma clang diagnostic pop
    
    if (CALL_METHOD_IS("enableWebviewRecording")) {
        DLog(@"-> %@", call.method);
        BOOL enabled = BOOL_VALUE_OR_DEFAULT(call.arguments[@"enabled"], 0);
        if (enabled) {
            [Smartlook registerWhitelistedObject:[WKWebView class]];
        } else {
            [Smartlook registerBlacklistedObject:[WKWebView class]];
        }
        return;
    }
    
    
    
    // MARK: Event Tracking Mode
    if (CALL_METHOD_IS("setEventTrackingMode")) {
        DLog(@"-> %@", call.method);
        if (IS_STRING_WITH_VALUE(call.arguments[@"eventTrackingMode"])) {
            NSString *eventTrackingMode = flutterEventTrackingModeToNative[call.arguments[@"eventTrackingMode"]];
            if (eventTrackingMode != nil) {
                [Smartlook setEventTrackingModeTo:eventTrackingMode];
            }
        }
        return;
    }

    if (CALL_METHOD_IS("setEventTrackingModes")) {
        DLog(@"-> %@", call.method);
        DLog(@"eventTrackingModes: %@", call.arguments[@"eventTrackingModes"]);
        NSMutableArray<SLEventTrackingMode> *nativeEventTrackingModes = [NSMutableArray new];
        NSArray<NSString *> *eventTrackingModes = call.arguments[@"eventTrackingModes"];
        if ([eventTrackingModes isKindOfClass:[NSArray class]]) {
            [eventTrackingModes enumerateObjectsUsingBlock:^(NSString * _Nonnull eventTrackingMode, NSUInteger idx, BOOL * _Nonnull stop) {
                if (IS_STRING_WITH_VALUE(eventTrackingMode)) {
                    NSString *nativeEventTrackingMode = flutterEventTrackingModeToNative[eventTrackingMode];
                    if (nativeEventTrackingMode != nil) {
                        [nativeEventTrackingModes addObject:nativeEventTrackingMode];
                    };
                };
            }];
        }
        [Smartlook setEventTrackingModesTo:nativeEventTrackingModes];
        return;
    }

    // MARK: Global Properties
    if (CALL_METHOD_IS("setGlobalEventProperty")) {
        DLog(@"-> %@", call.method);
        NSString *name = call.arguments[@"key"];
        NSString *value = call.arguments[@"value"];
        if (!IS_STRING_WITH_VALUE(name) || !IS_STRING_WITH_VALUE(value)) {
            return;
        }
        SLPropertyOption option = BOOL_VALUE_OR_DEFAULT(call.arguments[@"immutable"], NO) ? SLPropertyOptionImmutable : SLPropertyOptionDefaults;
        [Smartlook setGlobalEventPropertyValue:value forName:name withOptions:option];
        return;
    }
    if (CALL_METHOD_IS("setGlobalEventProperties")) {
        DLog(@"-> %@", call.method);
        NSDictionary *map = call.arguments[@"map"];
        if ([map respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
            SLPropertyOption option = BOOL_VALUE_OR_DEFAULT(call.arguments[@"immutable"], NO) ? SLPropertyOptionImmutable : SLPropertyOptionDefaults;
            [map enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, id _Nonnull value, BOOL * _Nonnull stop) {
                [Smartlook setGlobalEventPropertyValue:value forName:name withOptions:option];
            }];
        };
        return;
    }
    if (CALL_METHOD_IS("removeGlobalEventProperty")) {
        DLog(@"-> %@", call.method);
        NSString *key = call.arguments[@"key"];
        if (IS_STRING_WITH_VALUE(key)) {
            [Smartlook removeGlobalEventPropertyForName:key];
        }
        return;
    }
    if (CALL_METHOD_IS("removeAllGlobalEventProperties")) {
        DLog(@"-> %@", call.method);
        [Smartlook clearGlobalEventProperties];
        return;
    }
    
    
    // MARK: Integrations
    if (CALL_METHOD_IS("getDashboardSessionUrl")) {
        DLog(@"-> %@", call.method);
        BOOL withCurrentTimestamp = BOOL_VALUE_OR_DEFAULT(call.arguments[@"withCurrentTimestamp"], NO);
        NSString *rval = [Smartlook getDashboardSessionURLWithCurrentTimestamp:withCurrentTimestamp].absoluteString;
        result(rval);
        return;
    }
    
    if (CALL_METHOD_IS("getDashboardVisitorUrl")) {
        DLog(@"-> %@", call.method);
        result([Smartlook getDashboardVisitorURL].absoluteString);
        return;
    }
    
    // MARK: Rendering Mode
    if (CALL_METHOD_IS("setRenderingMode")) {
        DLog(@"-> %@", call.method);
        SLRenderingMode renderingMode = INT_VALUE_OR_DEFAULT(call.arguments[@"renderingMode"], 0) == 0 ? SLRenderingModeNative : SLRenderingModeNoRendering;
        [Smartlook setRenderingModeTo:renderingMode];
        return;
    }
    
    
    
    // MARK: Not available on iOS
    if (CALL_METHOD_IS("setReferrer")) {
        // not available on iOS
        DLog(@"-> %@", call.method);
        return;
    }
    if (CALL_METHOD_IS("flush")) {
        // not available on iOS
        DLog(@"-> %@", call.method);
        return;
    }
    if (CALL_METHOD_IS("enableCrashlytics")) {
        // not available on iOS
        DLog(@"-> %@", call.method);
        return;
    }
    
    
    // MARK: Default
    DLog(@"Smartlook: method not found -> %@", call.method);
    result(FlutterMethodNotImplemented);
    
}

@end
