import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_storm/bridge/flags.dart';
import 'dart:async';

import 'package:flutter_storm/flutter_storm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    displayOTRContents();
  }

  Future<void> displayOTRContents() async {
    String? mpqHandle = await SFileOpenArchive(
        "/Users/dcvz/Downloads/generated.otr", MPQ_OPEN_READ_ONLY);

    if (mpqHandle == null) {
      print("Failed to open archive");
      return;
    }

    String? findData = await SFileFindCreateDataPointer();
    if (findData == null) {
      print("Failed to create find data");
      return;
    }

    String? hFind = await SFileFindFirstFile(mpqHandle, "*", findData);
    if (hFind == null) {
      print("Failed to find first file");
      return;
    }

    bool fileFound = false;
    List<String> files = [];

    do {
      fileFound = await SFileFindNextFile(hFind, findData) == 0;
      if (fileFound) {
        print("Found file!");
        String? fileName = await SFileFindGetDataForDataPointer(findData);
        print(fileName);
        if (fileName != null && fileName != "(signature)") {
          files.add(fileName);
        }
      } else if (!fileFound /*&& GetLastError() != ERROR_NO_MORE_FILES*/) {}
    } while (fileFound);

    SFileFindClose(hFind);
    print(files);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> writeDemoFile() async {
    String? mpqHandle = await SFileCreateArchive(
        "/Users/dcvz/Github/flutter_storm/Demo.mpq",
        MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V4,
        1024);

    File data = File("/Users/dcvz/Downloads/accessibility_text_eng.xml");

    String? fileHandle = await SFileCreateFile(
        mpqHandle!, "DemoFile.uwu", data.lengthSync(), MPQ_FILE_COMPRESS);
    await SFileWriteFile(fileHandle!, data.readAsBytesSync(), data.lengthSync(),
        MPQ_COMPRESSION_ZLIB);

    if (!mounted) return;

    setState(() {
      _platformVersion = "Current handle ${mpqHandle}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
