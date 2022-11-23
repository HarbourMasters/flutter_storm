import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_storm_platform_interface.dart';

class MethodChannelFlutterStorm extends FlutterStormPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_storm');

  @override
  Future<int?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
    final handle = await methodChannel.invokeMethod<int>('SFileCreateArchive', {
      'mpqName': mpqName,
      'mpqFlags': mpqFlags,
      'maxFileCount': maxFileCount
    });
    return handle;
  }

  Future<int?> SFileCloseArchive(int hMpq) async {
    final handle = await methodChannel.invokeMethod<int>('SFileCloseArchive', {
      'hMpq': hMpq
    });
    return handle;
  }

  @override
  Future<int?> SFileCreateFile(int hFile, String fileName, int fileTime, int fileSize, int dwFlags) async {
    final handle = await methodChannel.invokeMethod<int>('SFileCreateFile', {
      'hFile': hFile,
      'fileName': fileName,
      'fileTime': fileTime,
      'fileSize': fileSize,
      'dwFlags': dwFlags
    });
    return handle;
  }

  @override
  Future<int?> SFileWriteFile(int hFile, Uint8List pvData, int dwSize, int dwCompression) async {
    final handle = await methodChannel.invokeMethod<int>('SFileWriteFile', {
      'hFile': hFile,
      'pvData': pvData,
      'dwSize': dwSize,
      'dwCompression': dwCompression
    });
    return handle;
  }

  @override
  Future<int?> SFileFinishFile(int hFile) async {
    final handle = await methodChannel.invokeMethod<int>('SFileFinishFile', {
      'handle': hFile
    });
    return handle;
  }
}
