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
    writeDemoFile();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> writeDemoFile() async {
    int? mpqHandle = await SFileCreateArchive("I:\\Demo.mpq", MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V4, 1024);

    File data = File("C:\\Users\\Ruine\\3D Objects\\lewd.png");

    int? fileHandle = await SFileCreateFile(mpqHandle!, "DemoFile.uwu", data.lengthSync(), MPQ_FILE_COMPRESS);
    await SFileWriteFile(fileHandle!, data.readAsBytesSync(), data.lengthSync(), MPQ_COMPRESSION_ZLIB);
    await SFileFinishFile(fileHandle);
    await SFileCloseArchive(mpqHandle);

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
