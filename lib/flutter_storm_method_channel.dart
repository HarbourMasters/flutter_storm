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

  Future<int?> SFileCloseArchive(String hMpq) async {
    final handle = await methodChannel.invokeMethod<int>('SFileCloseArchive', {
      'hMpq': hMpq
    });
    return handle;
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
  Future<int?> SFileCloseFile(String hFile) async {
    final handle = await methodChannel
        .invokeMethod<int>('SFileCloseFile', {'hFile': hFile});
    return handle;
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
    await methodChannel.invokeMethod<int>('SFileRemoveFile', {
      'hMpq': hMpq,
      'fileName': fileName
    });
  }

  @override
  Future<void> SFileRenameFile(String hMpq, String oldFileName, String newFileName) async {
    await methodChannel.invokeMethod<int>('SFileRenameFile', {
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
  Future<int?> SFileFindNextFile(String hFind, String lpFindFileData) async {
    final handle = await methodChannel.invokeMethod<int>('SFileFindNextFile', {
      'hFind': hFind,
      'lpFindFileData': lpFindFileData
    });
    return handle;
  }

  @override
  Future<int?> SFileFindClose(String hFind) async {
    final handle = await methodChannel.invokeMethod<int>('SFileFindClose', {
      'hFind': hFind
    });
    return handle;
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
