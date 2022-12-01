import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_storm_platform_interface.dart';

class MethodChannelFlutterStorm extends FlutterStormPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_storm');

  @override
  Future<String?> SFileOpenArchive(String mpqName, int mpqFlags) async {
    final handle = await methodChannel.invokeMethod<String>('SFileOpenArchive', {
      'mpqName': mpqName,
      'mpqFlags': mpqFlags
    });
    return handle;
  }

  @override
  Future<String?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
    final handle = await methodChannel.invokeMethod<String>('SFileCreateArchive', {
      'mpqName': mpqName,
      'mpqFlags': mpqFlags,
      'maxFileCount': maxFileCount
    });
    return handle;
  }

  Future<void> SFileCloseArchive(String hMpq) async {
    await methodChannel.invokeMethod<void>('SFileCloseArchive', {
      'hMpq': hMpq
    });
  }

  @override
  Future<bool?> SFileHasFile(String hMpq, String fileName, int fileSize, int dwFlags) async {
    final handle = await methodChannel.invokeMethod<bool>('SFileHasFile', {
      'hMpq': hMpq,
      'fileName': fileName
    });
    return handle;
  }

  @override
  Future<String?> SFileCreateFile(String hMpq, String fileName, int fileSize, int dwFlags) async {
    final handle = await methodChannel.invokeMethod<String>('SFileCreateFile', {
      'hMpq': hMpq,
      'fileName': fileName,
      'fileSize': fileSize,
      'dwFlags': dwFlags
    });
    return handle;
  }

  @override
  Future<void> SFileCloseFile(String hFile) async {
    await methodChannel
        .invokeMethod<void>('SFileCloseFile', {'hFile': hFile});
  }

  @override
  Future<void> SFileWriteFile(String hFile, Uint8List pvData, int dwSize, int dwCompression) async {
    await methodChannel.invokeMethod<void>('SFileWriteFile', {
      'hFile': hFile,
      'pvData': pvData,
      'dwSize': dwSize,
      'dwCompression': dwCompression
    });
  }

  @override
  Future<void> SFileRemoveFile(String hMpq, String fileName) async {
    await methodChannel.invokeMethod<void>('SFileRemoveFile', {
      'hMpq': hMpq,
      'fileName': fileName
    });
  }

  @override
  Future<void> SFileRenameFile(String hMpq, String oldFileName, String newFileName) async {
    await methodChannel.invokeMethod<void>('SFileRenameFile', {
      'hMpq': hMpq,
      'oldFileName': oldFileName,
      'newFileName': newFileName
    });
  }


  @override
  Future<void> SFileFinishFile(String hFile) async {
    await methodChannel.invokeMethod<void>('SFileFinishFile', {
      'hFile': hFile
    });
  }

  @override
  Future<String?> SFileFindFirstFile(String hMpq, String szMask, String lpFindFileData) async {
    final handle = await methodChannel.invokeMethod<String>('SFileFindFirstFile', {
      'hMpq': hMpq,
      'szMask': szMask,
      'lpFindFileData': lpFindFileData
    });
    return handle;
  }

  @override
  Future<void> SFileFindNextFile(String hFind, String lpFindFileData) async {
    await methodChannel.invokeMethod<void>('SFileFindNextFile', {
      'hFind': hFind,
      'lpFindFileData': lpFindFileData
    });
  }

  @override
  Future<void> SFileFindClose(String hFind) async {
    await methodChannel.invokeMethod<void>('SFileFindClose', {
      'hFind': hFind
    });
  }

  // Custom Methods

  @override
  Future<String?> SFileFindCreateDataPointer() async {
    final handle = await methodChannel.invokeMethod<String>('SFileFindCreateDataPointer');
    return handle;
  }

  @override
  Future<String?> SFileFindGetDataForDataPointer(String lpFindFileData) async {
    final handle = await methodChannel.invokeMethod<String>('SFileFindGetDataForDataPointer', {
      'lpFindFileData': lpFindFileData
    });
    return handle;
  }
}
