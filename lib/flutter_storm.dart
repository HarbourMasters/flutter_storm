import 'dart:typed_data';
import 'flutter_storm_platform_interface.dart';

Future<int?> SFileOpenArchive(String mpqName, int mpqFlags) async {
  return FlutterStormPlatform.instance.SFileOpenArchive(mpqName, mpqFlags);
}

Future<int?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
  return FlutterStormPlatform.instance.SFileCreateArchive(mpqName, mpqFlags, maxFileCount);
}

Future<int?> SFileCloseArchive(int hMpq) async {
  return FlutterStormPlatform.instance.SFileCloseArchive(hMpq);
}

Future<bool?> SFileHasFile(int hMpq, String fileName, int fileSize, int dwFlags) async {
  return FlutterStormPlatform.instance.SFileHasFile(hMpq, fileName, fileSize, dwFlags);
}

Future<int?> SFileCreateFile(int hMpq, String fileName, int fileSize, int dwFlags) async {
  return FlutterStormPlatform.instance.SFileCreateFile(hMpq, fileName, fileSize, dwFlags);
}

Future<int?> SFileCloseFile(int hFile) async {
  return FlutterStormPlatform.instance.SFileCloseFile(hFile);
}

Future<void> SFileWriteFile(int hFile, Uint8List pvData, int dwSize, int dwCompression) async {
  return FlutterStormPlatform.instance.SFileWriteFile(hFile, pvData, dwSize, dwCompression);
}

Future<void> SFileRemoveFile(int hMpq, String fileName) async {
  return FlutterStormPlatform.instance.SFileRemoveFile(hMpq, fileName);
}

Future<void> SFileRenameFile(int hMpq, String oldFileName, String newFileName) async {
  return FlutterStormPlatform.instance.SFileRenameFile(hMpq, oldFileName, newFileName);
}

Future<void> SFileFinishFile(int hFile) async {
  return FlutterStormPlatform.instance.SFileFinishFile(hFile);
}