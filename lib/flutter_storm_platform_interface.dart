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

  Future<int?> SFileOpenArchive(String mpqName, int mpqFlags) async {
    throwUnimplemented();
  }

  Future<int?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
    throwUnimplemented();
  }

  Future<int?> SFileCloseArchive(int hMpq) async {
    throwUnimplemented();
  }

  Future<bool?> SFileHasFile(int hMpq, String fileName, int fileSize, int dwFlags) async {
    throwUnimplemented();
  }

  Future<int?> SFileCreateFile(int hMpq, String fileName, int fileSize, int dwFlags) async {
    throwUnimplemented();
  }

  Future<void> SFileWriteFile(int hFile, Uint8List pvData, int dwSize, int dwCompression) async {
    throwUnimplemented();
  }

  Future<void> SFileRemoveFile(int hMpq, String fileName) async {
    throwUnimplemented();
  }

  Future<void> SFileRenameFile(int hMpq, String oldFileName, String newFileName) async {
    throwUnimplemented();
  }

  Future<void> SFileFinishFile(int hFile) async {
    throwUnimplemented();
  }
}
