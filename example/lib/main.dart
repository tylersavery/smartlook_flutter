import 'package:flutter/material.dart';
import 'dart:async';

import 'package:smartlook/smartlook.dart';
import 'dart:collection';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class CustomIntegrationListener implements IntegrationListener {
  void onSessionReady(String? dashboardSessionUrl) {
    print("DashboardUrl:");
    print(dashboardSessionUrl);
  }

  void onVisitorReady(String? dashboardVisitorUrl) {
    print("DashboardVisitorUrl:");
    print(dashboardVisitorUrl);
  }
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String _timeString = "";

  @override
  void initState() {
    super.initState();
    
    _timeString = "${DateTime.now().hour} : ${DateTime.now().minute} :${DateTime.now().second}";
    Timer.periodic(Duration(seconds:1), (Timer t)=>_getCurrentTime());
    
    SetupOptions options = (
      new SetupOptionsBuilder('API_KEY')
      ..Fps = 2
      ..StartNewSession = true
      ).build();

    Smartlook.setupAndStartRecording(options);

    // calling all functions to make sure nothing crashes
    Smartlook.setEventTrackingMode(EventTrackingMode.FULL_TRACKING);    
    List<EventTrackingMode> a = [EventTrackingMode.FULL_TRACKING, EventTrackingMode.IGNORE_USER_INTERACTION];
    Smartlook.setEventTrackingModes(a);    
    Smartlook.registerIntegrationListener(new CustomIntegrationListener());
    Smartlook.setUserIdentifier('FlutterLul', { "flutter-usr-prop" : "valueX"});
    Smartlook.setGlobalEventProperty("key_", "value_", true);
    Smartlook.setGlobalEventProperties( { "A" : "B"}, false);
    Smartlook.removeGlobalEventProperty("A");
    Smartlook.removeAllGlobalEventProperties();
    Smartlook.setGlobalEventProperty("flutter_global", "value_", true);
    Smartlook.enableWebviewRecording(true);
    Smartlook.enableWebviewRecording(false);
    Smartlook.enableCrashlytics(true);
    Smartlook.setReferrer("referer", "source");
    Smartlook.getDashboardSessionUrl(true);
  }

  void _getCurrentTime()  {
    setState(() {
    _timeString = "${DateTime.now().hour} : ${DateTime.now().minute} :${DateTime.now().second}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          //child: Text('Running on: $_platformVersion\n'),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

            Image.asset("lib/Smartlook.png"),

            Text(_timeString, style: TextStyle(fontSize: 18),),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.stopRecording();
              },
              child: Text('Stop recording'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.startRecording();
              },
              child: Text('Start recording'),
            ),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.startTimedCustomEvent("timed-event");
              },
              child: Text('Start timed event'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.trackCustomEvent("timed-event", { "property1" : "value1" });
              },
              child: Text('Track event'),
            ),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.startFullscreenSensitiveMode();
              },
              child: Text('Start Sensitive Mode'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.stopFullscreenSensitiveMode();
              },
              child: Text('Stop Sensitive Mode'),
            ),

            const SizedBox(height: 15),
            RaisedButton(
              onPressed: () {
                Smartlook.trackNavigationEvent("nav-event", SmartlookNavigationEventType.enter);
              },
              child: Text('Enter Navigation Event'),
            ),
            RaisedButton(
              onPressed: () {
                Smartlook.trackNavigationEvent("nav-event", SmartlookNavigationEventType.exit);
              },
              child: Text('Exit Navigation Event'),
            ),
              
            ],
          ),
        ),      
      ),
    );
  }
}
