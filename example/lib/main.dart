import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_platform_interface.dart';

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
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    int? mpqHandle = await FlutterStormPlatform.instance.SFileCreateArchive("I:\\Demo.mpq", MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V4, 1024);

    File data = File("C:\\Users\\Ruine\\3D Objects\\lewd.png");

    int? fileHandle = await FlutterStormPlatform.instance.SFileCreateFile(mpqHandle!, "DemoFile.uwu", 0, data.lengthSync(), MPQ_FILE_COMPRESS);
    await FlutterStormPlatform.instance.SFileWriteFile(fileHandle!, data.readAsBytesSync(), data.lengthSync(), MPQ_COMPRESSION_ZLIB);
    await FlutterStormPlatform.instance.SFileFinishFile(fileHandle);
    await FlutterStormPlatform.instance.SFileCloseArchive(mpqHandle);

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
