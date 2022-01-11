package com.Smartlook.Smartlook.smartlook;

import android.webkit.WebView;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import org.json.JSONObject;
import com.smartlook.sdk.smartlook.Smartlook;
import com.smartlook.sdk.smartlook.IntegrationListener;
import com.smartlook.sdk.smartlook.analytics.event.annotations.EventTrackingMode;
import java.util.HashMap;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.ArrayList;

/** SmartlookPlugin */
public class SmartlookPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "smartlook");
    channel.setMethodCallHandler(new SmartlookPlugin());
    final EventChannel eventChannel = new EventChannel(registrar.messenger(), "smartlookEvent");
    eventChannel.setStreamHandler(new StreamHandler() {
      @Override
      public void onListen(Object arguments, final EventSink eventSink) {
          Smartlook.registerIntegrationListener(new IntegrationListener() {
                @Override
                public void onSessionReady(String dashboardSessionUrl) {
                  eventSink.success(dashboardSessionUrl);
                }

                @Override
                public void onVisitorReady(String dashboardVisitorUrl) {
                  eventSink.success(dashboardVisitorUrl);
                }
            });
          
        }

        @Override
        public void onCancel(Object args) {
          Smartlook.unregisterIntegrationListener();
        }
      });
  }

  private Gson gson = null;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("setupAndStartRecordingBridge")) {
      String options = call.argument("options");
      Smartlook.setupAndStartRecordingBridge(options);
    } else if (call.method.equals("setupBridge")) {
      String options = call.argument("options");
      Smartlook.setupBridge(options);
    } else if (call.method.equals("isRecording")) {
      result.success(Smartlook.isRecording());
    } else if (call.method.equals("startFullscreenSensitiveMode")) {
      Smartlook.startFullscreenSensitiveMode();
    } else if (call.method.equals("stopFullscreenSensitiveMode")) {
      Smartlook.stopFullscreenSensitiveMode();
    } else if (call.method.equals("isFullscreenSensitiveModeActive")) {
      result.success(Smartlook.isFullscreenSensitiveModeActive());
    } else if (call.method.equals("setReferrer")) {
      String referrer = call.argument("referrer");
      String source = call.argument("source");
      Smartlook.setReferrer(referrer, source);
    } else if (call.method.equals("trackNavigationEvent")) {
      String navKey = call.argument("key");
      int direction = call.argument("type");
      String viewDirection = "start";
      if (direction == 0) viewDirection = "start"; else viewDirection = "stop";
      Smartlook.trackNavigationEvent(navKey, "activity", viewDirection);
    } else if (call.method.equals("getDashboardSessionUrl")) {
      boolean withCurrentTimestamp = call.argument("withCurrentTimestamp");
      result.success(Smartlook.getDashboardSessionUrl(withCurrentTimestamp));
    } else if (call.method.equals("getDashboardVisitorUrl")) {
      result.success(Smartlook.getDashboardVisitorUrl());
    } else if (call.method.equals("resetSession")) {
      boolean resetUser = call.argument("resetUser");
      Smartlook.resetSession(resetUser);
    } else if (call.method.equals("startRecording")) {
      Smartlook.startRecording();
    } else if (call.method.equals("stopRecording")) {
      Smartlook.stopRecording();
    } else if (call.method.equals("flush")) {
      //Smartlook.flush();
    } else if (call.method.equals("removeAllGlobalEventProperties")) {
      Smartlook.removeAllGlobalEventProperties();
    } else if (call.method.equals("removeGlobalEventProperty")) {
      String propertyKey = call.argument("key");
      Smartlook.removeGlobalEventProperty(propertyKey);
    }
      else if (call.method.equals("setGlobalEventProperty")) {
      String propertyKey = call.argument("key");
      String propertyValue = call.argument("value");
      boolean immutable = call.argument("immutable");
      Smartlook.setGlobalEventProperty(propertyKey, propertyValue, immutable);
    } else if (call.method.equals("setGlobalEventProperties")) {
      HashMap globalImmutableProperties = call.argument("map");
      boolean immutable = call.argument("immutable");

      if (globalImmutableProperties != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(globalImmutableProperties,gsonType);
        Smartlook.setGlobalEventProperties(gsonString, immutable);
      }
    } else if (call.method.equals("startTimedCustomEvent")) {
      String eventKey = call.argument("key");
      HashMap eventMap = call.argument("map");

      if (eventKey != null && eventMap != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(eventMap,gsonType);
        result.success(Smartlook.startTimedCustomEvent(eventKey, gsonString));
      } else if (eventKey != null) {
        result.success(Smartlook.startTimedCustomEvent(eventKey));
      }
    } else if (call.method.equals("stopTimedCustomEvent")) {
      String eventKey = call.argument("key");
      HashMap eventMap = call.argument("map");

      if (eventKey != null && eventMap != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(eventMap,gsonType);
        Smartlook.stopTimedCustomEvent(eventKey, gsonString);
      } else if (eventKey != null) {
        Smartlook.stopTimedCustomEvent(eventKey);
      }
    } else if (call.method.equals("cancelTimedCustomEvent")) {
      String eventKey = call.argument("key");
      String reason = call.argument("reason");
      HashMap eventMap = call.argument("map");

      if (eventKey != null && eventMap != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(eventMap,gsonType);
        Smartlook.cancelTimedCustomEvent(eventKey, reason, gsonString);
      } else if (eventKey != null) {
        Smartlook.cancelTimedCustomEvent(eventKey, reason);
      }
    } else if (call.method.equals("enableCrashlytics")) {
      boolean enabled = call.argument("enabled");
      Smartlook.enableCrashlytics(enabled);
    } else if (call.method.equals("enableWebviewRecording")) {
      boolean enabled = call.argument("enabled");
      if (enabled) {
        Smartlook.unregisterBlacklistedClass(WebView.class);
      } else {
        Smartlook.registerBlacklistedClass(WebView.class);
      }
    } else if (call.method.equals("trackCustomEvent")) {
      String eventKey = call.argument("key");
      HashMap eventMap = call.argument("map");

      if (eventKey != null && eventMap != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(eventMap,gsonType);
        Smartlook.trackCustomEvent(eventKey, gsonString);
      } else if (eventKey != null) {
        Smartlook.trackCustomEvent(eventKey);
      }
    } else if (call.method.equals("setUserIdentifier")) {
      String identifyKey = call.argument("key");
      HashMap identifyMap = call.argument("map");

      if (identifyKey != null && identifyMap != null) {
        if (gson == null) {
          gson = new Gson();
        }
        Type gsonType = new TypeToken<HashMap>(){}.getType();
        String gsonString = gson.toJson(identifyMap,gsonType);
        Smartlook.setUserIdentifier(identifyKey);
        Smartlook.setUserProperties(gsonString, false);
      } else if (identifyKey != null) {
        Smartlook.setUserIdentifier(identifyKey);
      }
    } else if (call.method.equals("setRenderingMode")) {
      int renderingMethodKey = call.argument("renderingMode");
      String renderingMethod = "native";
      if (renderingMethodKey == 0) renderingMethod = "native"; else renderingMethod = "no_rendering";
      Smartlook.setRenderingMode(renderingMethod);
    } else if (call.method.equals("setEventTrackingMode")) {
      String eventTrackingModeKey = call.argument("eventTrackingMode");
      Smartlook.setEventTrackingMode(EventTrackingMode.valueOf(eventTrackingModeKey));
    } else if (call.method.equals("setEventTrackingModes")) {
      ArrayList<String> eventTrackingStringModes = call.argument("eventTrackingModes");
      ArrayList<EventTrackingMode> eventTrackingModes = new ArrayList<EventTrackingMode>();
      if (eventTrackingStringModes.size() > 0) {
        for (String mode : eventTrackingStringModes) {
          eventTrackingModes.add(EventTrackingMode.valueOf(mode));
        }
        
        Smartlook.setEventTrackingModes(eventTrackingModes);
      }
    } else {
            result.notImplemented();
    }
  }
}
