import 'dart:typed_data';
import 'flutter_storm_platform_interface.dart';

Future<int?> SFileCreateArchive(String mpqName, int mpqFlags, int maxFileCount) async {
  return FlutterStormPlatform.instance.SFileCreateArchive(mpqName, mpqFlags, maxFileCount);
}

Future<int?> SFileCloseArchive(int hMpq) async {
  return FlutterStormPlatform.instance.SFileCloseArchive(hMpq);
}

Future<int?> SFileCreateFile(int hMpq, String fileName, int fileSize, int dwFlags) async {
  return FlutterStormPlatform.instance.SFileCreateFile(hMpq, fileName, fileSize, dwFlags);
}

Future<void> SFileWriteFile(int hFile, Uint8List pvData, int dwSize, int dwCompression) async {
  return FlutterStormPlatform.instance.SFileWriteFile(hFile, pvData, dwSize, dwCompression);
}

Future<void> SFileFinishFile(int hFile) async {
  return FlutterStormPlatform.instance.SFileFinishFile(hFile);
}