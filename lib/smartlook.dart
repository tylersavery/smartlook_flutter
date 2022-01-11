import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert' show jsonDecode, jsonEncode;

enum SmartlookNavigationEventType { enter, exit }
enum SmartlookRenderingMode { native, no_rendering }
enum EventTrackingMode { FULL_TRACKING, IGNORE_USER_INTERACTION, IGNORE_NAVIGATION_INTERACTION, IGNORE_RAGE_CLICKS, NO_TRACKING }

String describeEnum(Object enumEntry) {
    final String description = enumEntry.toString();
    final int indexOfDot = description.indexOf('.');
    assert(indexOfDot != -1 && indexOfDot < description.length - 1);
    return description.substring(indexOfDot + 1);
  }

@SL_COMPATIBILITY_NAME("name=IntegrationListener;type=callback;members=onSessionReady,onVisitorReady")
abstract class IntegrationListener {
    void onSessionReady(String? dashboardSessionUrl);
    void onVisitorReady(String? dashboardVisitorUrl);
  }

class SL_COMPATIBILITY_NAME {
  final String name;
  
  const SL_COMPATIBILITY_NAME(this.name);
}

class SetupOptionsBuilder {
  String ApiKey;
  int Fps = 2;
  bool StartNewSession = false;
  bool StartNewSessionAndUser = false;

  SetupOptionsBuilder(this.ApiKey);

  SetupOptions build() {
    return SetupOptions._builder(this);
  }
}

@SL_COMPATIBILITY_NAME("name=SetupOptions;type=builder;members=smartlookAPIKey,fps,startNewSession,startNewSessionAndUser")
class SetupOptions {
  final String ApiKey;
  final int Fps;
  final bool StartNewSession;
  final bool StartNewSessionAndUser;

  SetupOptions._builder(SetupOptionsBuilder builder) : 
    ApiKey = builder.ApiKey,
    Fps = builder.Fps,
    StartNewSession = builder.StartNewSession,
    StartNewSessionAndUser = builder.StartNewSessionAndUser;

  Map<String, dynamic> toJson() =>
    {
      'ApiKey': ApiKey,
      'Fps': Fps,
      'StartNewSession': StartNewSession,
      'StartNewSessionAndUser': StartNewSessionAndUser,
    };
}

class Smartlook {

	static const MethodChannel _channel =
		const MethodChannel('smartlook');

  static const EventChannel _eventChannel =
    const EventChannel('smartlookEvent');

  // SETUP
  @SL_COMPATIBILITY_NAME("name=setup;type=func;params=setupOptions{SetupOptions}")
  static void setup(SetupOptions options) async{
    await _channel. invokeMethod('setupBridge',{"options": jsonEncode(options.toJson())});
  }

  @SL_COMPATIBILITY_NAME("name=setupAndStartRecording;type=func;params=setupOptions{SetupOptions}")
  static Future<void> setupAndStartRecording(SetupOptions options) async{
    await _channel. invokeMethod('setupAndStartRecordingBridge',{"options": jsonEncode(options.toJson())});
  }

  @SL_COMPATIBILITY_NAME("name=setUserIdentifier;type=func;params=identifier{string}")
  @SL_COMPATIBILITY_NAME("name=setUserProperties;type=func;params=sessionProperties{JSONObject},immutable{boolean}")
  @SL_COMPATIBILITY_NAME("name=setUserProperties;type=func;params=sessionProperties{Bundle},immutable{boolean}")
  @SL_COMPATIBILITY_NAME("name=setUserProperties;type=func;params=sessionProperties{string},immutable{boolean}")
  static Future<void> setUserIdentifier(String key, [Object? map = null]) async{
    await _channel. invokeMethod('setUserIdentifier',{"key":key, "map":map});
  }

  // START & STOP
  @SL_COMPATIBILITY_NAME("name=startRecording;type=func")
  static Future<void> startRecording() async{
    await _channel. invokeMethod('startRecording');
  }

  @SL_COMPATIBILITY_NAME("name=stopRecording;type=func")
  static Future<void> stopRecording() async{
    await _channel. invokeMethod('stopRecording');
  }

  @SL_COMPATIBILITY_NAME("name=isRecording;type=func;returns=boolean")
  static Future<bool?> isRecording() async{
    bool? isRecording = await _channel.invokeMethod('isRecording');
    return isRecording;
  }

  // EVENTS
  @SL_COMPATIBILITY_NAME("name=startTimedCustomEvent;type=func;params=eventName{string};returns=string")
  @SL_COMPATIBILITY_NAME("name=startTimedCustomEvent;type=func;params=eventName{string},eventProperties{JSONObject};returns=string")
  @SL_COMPATIBILITY_NAME("name=startTimedCustomEvent;type=func;params=eventName{string},bundle{Bundle};returns=string")
  @SL_COMPATIBILITY_NAME("name=startTimedCustomEvent;type=func;params=eventName{string},eventProperties{string};returns=string")
  static Future<String?> startTimedCustomEvent(String key, [Object? map = null]) async{
    String? eventId = await _channel. invokeMethod('startTimedCustomEvent',{"key":key, "map":map});
    return eventId;
  }

  @SL_COMPATIBILITY_NAME("name=stopTimedCustomEvent;type=func;params=eventId{string}")
  @SL_COMPATIBILITY_NAME("name=stopTimedCustomEvent;type=func;params=eventId{string},eventProperties{JSONObject}")
  @SL_COMPATIBILITY_NAME("name=stopTimedCustomEvent;type=func;params=eventId{string},bundle{Bundle}")
  @SL_COMPATIBILITY_NAME("name=stopTimedCustomEvent;type=func;params=eventId{string},eventProperties{string}")
  static Future<void> stopTimedCustomEvent(String key, [Object? map = null]) async{
    await _channel. invokeMethod('stopTimedCustomEvent',{"key":key, "map":map});
  }

  @SL_COMPATIBILITY_NAME("name=cancelTimedCustomEvent;type=func;params=eventId{string},reason{string}")
  @SL_COMPATIBILITY_NAME("name=cancelTimedCustomEvent;type=func;params=eventId{string},reason{string},eventProperties{JSONObject}")
  @SL_COMPATIBILITY_NAME("name=cancelTimedCustomEvent;type=func;params=eventId{string},reason{string},bundle{Bundle}")
  @SL_COMPATIBILITY_NAME("name=cancelTimedCustomEvent;type=func;params=eventId{string},reason{string},eventProperties{string}")
  static Future<void> cancelTimedCustomEvent(String key, String reason, [Object? map = null]) async{
    await _channel. invokeMethod('cancelTimedCustomEvent',{"key":key, "reason":reason, "map":map});
  }

  @SL_COMPATIBILITY_NAME("name=trackCustomEvent;type=func;params=eventName{string}")
  @SL_COMPATIBILITY_NAME("name=trackCustomEvent;type=func;params=eventName{string},eventProperties{JSONObject}")
  @SL_COMPATIBILITY_NAME("name=trackCustomEvent;type=func;params=eventName{string},bundle{Bundle}")
  @SL_COMPATIBILITY_NAME("name=trackCustomEvent;type=func;params=eventName{string},properties{string}")
  static Future<void> trackCustomEvent(String key, [Object? map = null]) async{
  	await _channel. invokeMethod('trackCustomEvent',{"key":key, "map":map});
  }
 
  @SL_COMPATIBILITY_NAME("name=trackNavigationEvent;type=func;params=name{string},viewState{ViewState}")
  static Future<void> trackNavigationEvent(String key, SmartlookNavigationEventType type) async {
    await _channel. invokeListMethod("trackNavigationEvent", { "key": key, "type" : type.index } );
  }

  // SENSITIVE 
  @SL_COMPATIBILITY_NAME("name=startFullscreenSensitiveMode;type=func;deprecated=yes")
  static Future<void> startFullscreenSensitiveMode() async{
    await _channel. invokeMethod('startFullscreenSensitiveMode');
  }

  @SL_COMPATIBILITY_NAME("name=stopFullscreenSensitiveMode;type=func;deprecated=yes")
  static Future<void> stopFullscreenSensitiveMode() async{
    await _channel. invokeMethod('stopFullscreenSensitiveMode');
  }

  @SL_COMPATIBILITY_NAME("name=isFullscreenSensitiveModeActive;type=func;returns=boolean;deprecated=yes")
  static Future<bool?> isFullscreenSensitiveModeActive() async{
    bool? isFullscreenSesitiveMode = await _channel. invokeMethod('isFullscreenSensitiveModeActive');
    return isFullscreenSesitiveMode;
  }

  @SL_COMPATIBILITY_NAME("name=enableWebviewRecording;type=func;params=enabled{boolean};deprecated=yes")
  static Future<void> enableWebviewRecording(bool enabled) async{
  	await _channel. invokeMethod('enableWebviewRecording',{"enabled":enabled});
  }

  // GLOBAL EVENT PROPERTIES
  @SL_COMPATIBILITY_NAME("name=setGlobalEventProperty;type=func;params=key{string},value{string},immutable{boolean}")
  static Future<void> setGlobalEventProperty(String key, String value, bool immutable) async{
    await _channel. invokeMethod('setGlobalEventProperty',{ "key":key, "value": value, "immutable":immutable});
  }

  @SL_COMPATIBILITY_NAME("name=setGlobalEventProperties;type=func;params=globalEventProperties{JSONObject},immutable{boolean}")
  @SL_COMPATIBILITY_NAME("name=setGlobalEventProperties;type=func;params=globalEventProperties{Bundle},immutable{boolean}")
  @SL_COMPATIBILITY_NAME("name=setGlobalEventProperties;type=func;params=globalEventProperties{string},immutable{boolean}")
  static Future<void> setGlobalEventProperties(Object map, bool immutable) async{
    await _channel. invokeMethod('setGlobalEventProperties',{"map":map, "immutable":immutable});
  }

  @SL_COMPATIBILITY_NAME("name=removeGlobalEventProperty;type=func;params=key{string}")
  static Future<void> removeGlobalEventProperty(String key) async{
  	await _channel. invokeMethod('removeGlobalEventProperty',{"key":key});
  }

  @SL_COMPATIBILITY_NAME("name=removeAllGlobalEventProperties;type=func")
  static Future<void> removeAllGlobalEventProperties() async{
  	await _channel. invokeMethod('removeAllGlobalEventProperties');
  }

  // OTHERS
  @SL_COMPATIBILITY_NAME("name=setReferrer;type=func;params=referrer{string},source{string}")
	static Future<void> setReferrer(String referrer, String source) async{
   	await _channel. invokeMethod('setReferrer',{"referrer":referrer, "source":source});
	}

  @SL_COMPATIBILITY_NAME("name=getDashboardSessionUrl;type=func;params=withCurrentTimestamp{boolean};returns=string")
	static Future<String?> getDashboardSessionUrl(bool withCurrentTimestamp) async{
   	String? url = await _channel.invokeMethod('getDashboardSessionUrl',{"withCurrentTimestamp" : withCurrentTimestamp});
  	return url;
	}

  @SL_COMPATIBILITY_NAME("name=getDashboardVisitorUrl;type=func;returns=string")
  static Future<String?> getDashboardVisitorUrl() async{
    String? url = await _channel.invokeMethod('getDashboardVisitorUrl');
    return url;
  }

  @SL_COMPATIBILITY_NAME("name=enableCrashlytics;type=func;params=enable{boolean}")
  static Future<void> enableCrashlytics(bool enabled) async{
    await _channel.invokeMethod('enableCrashlytics',{"enabled":enabled});
  }

  @SL_COMPATIBILITY_NAME("name=resetSession;type=func;params=resetUser{boolean}")
  static Future<void> resetSession(bool resetUser) async{
    await _channel.invokeMethod('resetSession',{"resetUser":resetUser});
  }

  @SL_COMPATIBILITY_NAME("name=setRenderingMode;type=func;params=renderingMode{RenderingMode}")
  static Future<void> setRenderingMode(SmartlookRenderingMode renderingMode) async{
    await _channel.invokeMethod('setRenderingMode',{"renderingMode":renderingMode.index});
  }

  @SL_COMPATIBILITY_NAME("name=setEventTrackingMode;type=func;params=eventTrackingMode{EventTrackingMode}")
  static Future<void> setEventTrackingMode(EventTrackingMode eventTrackingMode) async{
    await _channel.invokeMethod('setEventTrackingMode',{"eventTrackingMode":describeEnum(eventTrackingMode)});
  }

  @SL_COMPATIBILITY_NAME("name=setEventTrackingModes;type=func;params=eventTrackingModes{List[EventTrackingMode]}")
  static Future<void> setEventTrackingModes(List<EventTrackingMode> eventTrackingModes) async{
    List<String> trackingModes = eventTrackingModes.map((mode) => describeEnum(mode)).toList();
    await _channel.invokeMethod('setEventTrackingModes',{"eventTrackingModes":trackingModes});
  }

  @SL_COMPATIBILITY_NAME("name=registerIntegrationListener;type=func;params=integrationListener{IntegrationListener}")
  static Future<void> registerIntegrationListener(IntegrationListener integrationListener) async{
    await _eventChannel.receiveBroadcastStream().listen((event) {
      //print(event);
      if (event.contains('visitor')) {
        integrationListener.onVisitorReady(event);
      } else {
        integrationListener.onSessionReady(event);
      }
    });
  }

}
