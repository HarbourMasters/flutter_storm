import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_platform_interface.dart';
import 'package:flutter_storm/flutter_storm_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterStormPlatform
    with MockPlatformInterfaceMixin
    implements FlutterStormPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterStormPlatform initialPlatform = FlutterStormPlatform.instance;

  test('$MethodChannelFlutterStorm is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterStorm>());
  });

  test('getPlatformVersion', () async {
    FlutterStorm flutterStormPlugin = FlutterStorm();
    MockFlutterStormPlatform fakePlatform = MockFlutterStormPlatform();
    FlutterStormPlatform.instance = fakePlatform;

    // expect(await flutterStormPlugin.getPlatformVersion(), '42');
  });
}
