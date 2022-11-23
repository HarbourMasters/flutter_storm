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

  Future<int?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
    throwUnimplemented();
  }

  Future<int?> SFileCloseArchive(int hMpq) async {
    throwUnimplemented();
  }

  Future<int?> SFileCreateFile(int hFile, String fileName, int fileTime, int fileSize, int dwFlags) async {
    throwUnimplemented();
  }

  Future<int?> SFileWriteFile(int hFile, Uint8List pvData, int dwSize, int dwCompression) async {
    throwUnimplemented();
  }

  Future<int?> SFileFinishFile(int hFile) async {
    throwUnimplemented();
  }
}
