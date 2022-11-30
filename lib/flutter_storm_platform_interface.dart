import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_storm_method_channel.dart';

abstract class FlutterStormPlatform extends PlatformInterface {

  FlutterStormPlatform() : super(token: _token);

  static final Object _token = Object();
  static FlutterStormPlatform _instance = MethodChannelFlutterStorm();
  static FlutterStormPlatform get instance => _instance;

  static set instance(FlutterStormPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void throwUnimplemented(){
    throw UnimplementedError('throwUnimplemented() has not been implemented.');
  }

  Future<String?> SFileOpenArchive(String mpqName, int mpqFlags) async {
    throwUnimplemented();
  }

  Future<String?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
    throwUnimplemented();
  }

  Future<int?> SFileCloseArchive(String hMpq) async {
    throwUnimplemented();
  }

  Future<bool?> SFileHasFile(String hMpq, String fileName, int fileSize, int dwFlags) async {
    throwUnimplemented();
  }

  Future<String?> SFileCreateFile(String hMpq, String fileName, int fileSize, int dwFlags) async {
    throwUnimplemented();
  }

  Future<int?> SFileCloseFile(String hFile) async {
    throwUnimplemented();
  }

  Future<void> SFileWriteFile(String hFile, Uint8List pvData, int dwSize, int dwCompression) async {
    throwUnimplemented();
  }

  Future<void> SFileRemoveFile(String hMpq, String fileName) async {
    throwUnimplemented();
  }

  Future<void> SFileRenameFile(String hMpq, String oldFileName, String newFileName) async {
    throwUnimplemented();
  }

  Future<void> SFileFinishFile(String hFile) async {
    throwUnimplemented();
  }

  Future<String?> SFileFindFirstFile(String hMpq, String szMask, String lpFindFileData) async {
    throwUnimplemented();
  }

  Future<int?> SFileFindNextFile(String hFind, String lpFindFileData) async {
    throwUnimplemented();
  }

  Future<int?> SFileFindClose(String hFind) async {
    throwUnimplemented();
  }

  // Custom Methods

  Future<String?> SFileFindCreateDataPointer() async {
    throwUnimplemented();
  }

  Future<String?> SFileFindGetDataForDataPointer(String lpFindFileData) async {
    throwUnimplemented();
  }
}
