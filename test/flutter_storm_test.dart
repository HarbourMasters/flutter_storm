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
  Future<int?> SFileCloseArchive(String hMpq) {
    // TODO: implement SFileCloseArchive
    throw UnimplementedError();
  }

  @override
  Future<int?> SFileCloseFile(String hFile) {
    // TODO: implement SFileCloseFile
    throw UnimplementedError();
  }

  @override
  Future<String?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) {
    // TODO: implement SFileCreateArchive
    throw UnimplementedError();
  }

  @override
  Future<String?> SFileCreateFile(String hMpq, String fileName, int fileSize, int dwFlags) {
    // TODO: implement SFileCreateFile
    throw UnimplementedError();
  }

  @override
  Future<int?> SFileFindClose(String hFind) {
    // TODO: implement SFileFindClose
    throw UnimplementedError();
  }

  @override
  Future<String?> SFileFindCreateDataPointer() {
    // TODO: implement SFileFindCreateDataPointer
    throw UnimplementedError();
  }

  @override
  Future<String?> SFileFindFirstFile(String hMpq, String szMask, String lpFindFileData) {
    // TODO: implement SFileFindFirstFile
    throw UnimplementedError();
  }

  @override
  Future<String?> SFileFindGetDataForDataPointer(String lpFindFileData) {
    // TODO: implement SFileFindGetDataForDataPointer
    throw UnimplementedError();
  }

  @override
  Future<int?> SFileFindNextFile(String hFind, String lpFindFileData) {
    // TODO: implement SFileFindNextFile
    throw UnimplementedError();
  }

  @override
  Future<void> SFileFinishFile(String hFile) {
    // TODO: implement SFileFinishFile
    throw UnimplementedError();
  }

  @override
  Future<bool?> SFileHasFile(String hMpq, String fileName, int fileSize, int dwFlags) {
    // TODO: implement SFileHasFile
    throw UnimplementedError();
  }

  @override
  Future<String?> SFileOpenArchive(String mpqName, int mpqFlags) {
    // TODO: implement SFileOpenArchive
    throw UnimplementedError();
  }

  @override
  Future<void> SFileRemoveFile(String hMpq, String fileName) {
    // TODO: implement SFileRemoveFile
    throw UnimplementedError();
  }

  @override
  Future<void> SFileRenameFile(String hMpq, String oldFileName, String newFileName) {
    // TODO: implement SFileRenameFile
    throw UnimplementedError();
  }

  @override
  Future<void> SFileWriteFile(String hFile, Uint8List pvData, int dwSize, int dwCompression) {
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
