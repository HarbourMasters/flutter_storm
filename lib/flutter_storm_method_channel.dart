// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_storm/bridge/errors.dart';

import 'flutter_storm_platform_interface.dart';

class MethodChannelFlutterStorm extends FlutterStormPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_storm');

  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    return methodChannel.invokeMethod<T>(method, arguments).catchError((ex) {
      throw StormException(message: ex.message ?? "Unknown error", error: StormError.values.firstWhere((e) => e.error == int.parse(ex.code), orElse: () => StormError.ERROR_UNKNOWN));
    });
  }

  @override
  Future<String?> SFileOpenArchive(String mpqName, int mpqFlags) async {
    final handle = await invokeMethod<String>('SFileOpenArchive', {
      'mpqName': mpqName,
      'mpqFlags': mpqFlags
    });
    return handle;
  }

  @override
  Future<String?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
    final handle = await invokeMethod<String>('SFileCreateArchive', {
      'mpqName': mpqName,
      'mpqFlags': mpqFlags,
      'maxFileCount': maxFileCount
    });
    return handle;
  }

  @override
  Future<void> SFileCloseArchive(String hMpq) async {
    await invokeMethod<void>('SFileCloseArchive', {
      'hMpq': hMpq
    });
  }

  @override
  Future<bool?> SFileHasFile(String hMpq, String fileName, int fileSize, int dwFlags) async {
    final handle = await invokeMethod<bool>('SFileHasFile', {
      'hMpq': hMpq,
      'fileName': fileName
    });
    return handle;
  }

  @override
  Future<String?> SFileCreateFile(String hMpq, String fileName, int fileSize, int dwFlags) async {
    final handle = await invokeMethod<String>('SFileCreateFile', {
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
    await invokeMethod<void>('SFileWriteFile', {
      'hFile': hFile,
      'pvData': pvData,
      'dwSize': dwSize,
      'dwCompression': dwCompression
    });
  }

  @override
  Future<void> SFileRemoveFile(String hMpq, String fileName) async {
    await invokeMethod<void>('SFileRemoveFile', {
      'hMpq': hMpq,
      'fileName': fileName
    });
  }

  @override
  Future<void> SFileRenameFile(String hMpq, String oldFileName, String newFileName) async {
    await invokeMethod<void>('SFileRenameFile', {
      'hMpq': hMpq,
      'oldFileName': oldFileName,
      'newFileName': newFileName
    });
  }


  @override
  Future<void> SFileFinishFile(String hFile) async {
    await invokeMethod<void>('SFileFinishFile', {
      'hFile': hFile
    });
  }

  @override
  Future<String?> SFileFindFirstFile(String hMpq, String szMask, String lpFindFileData) async {
    final handle = await invokeMethod<String>('SFileFindFirstFile', {
      'hMpq': hMpq,
      'szMask': szMask,
      'lpFindFileData': lpFindFileData
    });
    return handle;
  }

  @override
  Future<void> SFileFindNextFile(String hFind, String lpFindFileData) async {
    await invokeMethod<void>('SFileFindNextFile', {
      'hFind': hFind,
      'lpFindFileData': lpFindFileData
    });
  }

  @override
  Future<void> SFileFindClose(String hFind) async {
    await invokeMethod<void>('SFileFindClose', {
      'hFind': hFind
    });
  }

  @override
  Future<String?> SFileOpenFileEx(String hMpq, String szFileName, int dwSearchScope) async {
    final handle = await invokeMethod<String>('SFileOpenFileEx', {
      'hMpq': hMpq,
      'szFileName': szFileName,
      'dwSearchScope': dwSearchScope
    });
    return handle;
  }

  @override
  Future<int?> SFileGetFileSize(String hFile) async {
    final handle = await invokeMethod<int>('SFileGetFileSize', {
      'hFile': hFile
    });
    return handle;
  }

  // Custom Methods

  @override
  Future<String?> SFileFindCreateDataPointer() async {
    final handle = await invokeMethod<String>('SFileFindCreateDataPointer');
    return handle;
  }

  @override
  Future<String?> SFileFindGetDataForDataPointer(String lpFindFileData) async {
    final handle = await invokeMethod<String>('SFileFindGetDataForDataPointer', {
      'lpFindFileData': lpFindFileData
    });
    return handle;
  }
}
