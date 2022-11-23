import 'dart:typed_data';

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

  @override
  Future<int?> SFileCloseArchive(int hMpq) {
    // TODO: implement SFileCloseArchive
    throw UnimplementedError();
  }

  @override
  Future<int?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) {
    // TODO: implement SFileCreateArchive
    throw UnimplementedError();
  }

  @override
  Future<int?> SFileCreateFile(int hMpq, String fileName, int fileSize, int dwFlags) {
    // TODO: implement SFileCreateFile
    throw UnimplementedError();
  }

  @override
  Future<void> SFileFinishFile(int hFile) {
    // TODO: implement SFileFinishFile
    throw UnimplementedError();
  }

  @override
  Future<bool?> SFileHasFile(int hMpq, String fileName, int fileSize, int dwFlags) {
    // TODO: implement SFileHasFile
    throw UnimplementedError();
  }

  @override
  Future<int?> SFileOpenArchive(String mpqName, int mpqFlags) {
    // TODO: implement SFileOpenArchive
    throw UnimplementedError();
  }

  @override
  Future<void> SFileRemoveFile(int hMpq, String fileName) {
    // TODO: implement SFileRemoveFile
    throw UnimplementedError();
  }

  @override
  Future<void> SFileRenameFile(int hMpq, String oldFileName, String newFileName) {
    // TODO: implement SFileRenameFile
    throw UnimplementedError();
  }

  @override
  Future<void> SFileWriteFile(int hFile, Uint8List pvData, int dwSize, int dwCompression) {
    // TODO: implement SFileWriteFile
    throw UnimplementedError();
  }

  @override
  void throwUnimplemented() {
    // TODO: implement throwUnimplemented
  }
}

void main() {
  final FlutterStormPlatform initialPlatform = FlutterStormPlatform.instance;

  test('$MethodChannelFlutterStorm is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterStorm>());
  });

  test('getPlatformVersion', () async {
    MockFlutterStormPlatform fakePlatform = MockFlutterStormPlatform();
    FlutterStormPlatform.instance = fakePlatform;

    // expect(await flutterStormPlugin.getPlatformVersion(), '42');
  });
}
