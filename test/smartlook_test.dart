import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartlook/smartlook.dart';

void main() {
  const MethodChannel channel = MethodChannel('smartlook');
  String _platformVersion = 'Unknown';

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
