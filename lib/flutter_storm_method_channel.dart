import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_storm_platform_interface.dart';

class MethodChannelFlutterStorm extends FlutterStormPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_storm');

  @override
  Future<int?> SFileOpenArchive(String mpqName, int mpqFlags) async {
    final handle = await methodChannel.invokeMethod<int>('SFileOpenArchive', {
      'mpqName': mpqName,
      'mpqFlags': mpqFlags
    });
    return handle;
  }

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
  Future<bool?> SFileHasFile(int hMpq, String fileName, int fileSize, int dwFlags) async {
    final handle = await methodChannel.invokeMethod<bool>('SFileHasFile', {
      'hMpq': hMpq,
      'fileName': fileName
    });
    return handle;
  }

  @override
  Future<int?> SFileCreateFile(int hMpq, String fileName, int fileSize, int dwFlags) async {
    final handle = await methodChannel.invokeMethod<int>('SFileCreateFile', {
      'hMpq': hMpq,
      'fileName': fileName,
      'fileSize': fileSize,
      'dwFlags': dwFlags
    });
    return handle;
  }

  @override
  Future<int?> SFileCloseFile(int hFile) async {
    final handle = await methodChannel
        .invokeMethod<int>('SFileCloseFile', {'hFile': hFile});
    return handle;
  }

  @override
  Future<void> SFileWriteFile(int hFile, Uint8List pvData, int dwSize, int dwCompression) async {
    await methodChannel.invokeMethod<void>('SFileWriteFile', {
      'hFile': hFile,
      'pvData': pvData,
      'dwSize': dwSize,
      'dwCompression': dwCompression
    });
  }

  @override
  Future<void> SFileRemoveFile(int hMpq, String fileName) async {
    await methodChannel.invokeMethod<int>('SFileRemoveFile', {
      'hMpq': hMpq,
      'fileName': fileName
    });
  }

  @override
  Future<void> SFileRenameFile(int hMpq, String oldFileName, String newFileName) async {
    await methodChannel.invokeMethod<int>('SFileRenameFile', {
      'hMpq': hMpq,
      'oldFileName': oldFileName,
      'newFileName': newFileName
    });
  }


  @override
  Future<void> SFileFinishFile(int hFile) async {
    await methodChannel.invokeMethod<void>('SFileFinishFile', {
      'hFile': hFile
    });
  }

  @override
  Future<List<Object?>> SFileListArchive(int hMpq) async {
    final handle = await methodChannel.invokeMethod<List<Object?>>('SFileListArchive', {
      'hMpq': hMpq
    });

    return handle!;
  }
}
