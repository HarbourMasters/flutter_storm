import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_bindings_generated.dart';
import 'dart:async';

import 'package:flutter_storm_example/feedback.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

late PackageInfo packageInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  runApp(const MaterialApp(home: MyApp()));
}

String STORMLIB_VERSION = "v9.24";
String STORMLIB_REPO = "https://github.com/ladislav-zezula/StormLib";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;
  String? outputMPQ;
  MPQArchive? mpqArchive;
  final List<String> _otrFiles = [];
  final List<String> _outFiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3)
      ..addListener(() {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      });
  }

  Future<void> displayOTRContents(String file) async {
    MPQArchive? mpqArchive;
    try {
      mpqArchive = MPQArchive.open(file, 0, MPQ_OPEN_READ_ONLY);
    } on StormLibException catch (e) {
      print(e.message);
    }

    if (mpqArchive == null) {
      print("Failed to open archive");
      return;
    }

    MPQFindFileHandle hFind = MPQFindFileHandle();
    mpqArchive.findFirstFile("*", hFind, null);
    if (hFind == null) {
      print("Failed to find first file");
      return;
    }

    _otrFiles.clear();

    bool fileFound = false;

    do {
      try {
        mpqArchive.findNextFile(hFind);
        fileFound = true;
        String? fileName = hFind.fileName();
        if (fileName != null && fileName != "(signature)") {
          _otrFiles.add(fileName);
          print("Found file: $fileName");
        }
      } on StormLibException catch (e) {
        if (e.code == ERROR_NO_MORE_FILES) {
          print("Failed to get file name: $e");
          fileFound = false;
        }
      }
    } while (fileFound);

    print("Found ${_otrFiles.length} files");
    hFind.close();
    mpqArchive.close();
    setState(() {});
    return;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> writeDemoFile(String mpqPath, String filePath) async {
    File data = File(filePath);
    MPQCreateFileHandle file = mpqArchive!.createFile(
        filePath.split(Platform.pathSeparator).last,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        data.lengthSync(),
        0,
        MPQ_FILE_COMPRESS);
    file.write(data.readAsBytesSync(), data.lengthSync(), MPQ_COMPRESSION_ZLIB);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    defaultTab(text, IconData icon) {
      return Tab(
          icon: Icon(icon),
          child: Text(text, style: const TextStyle(color: Colors.black54)));
    }

    return Scaffold(
      floatingActionButton: _selectedIndex == 2
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (_selectedIndex == 0) {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['otr', 'mpq'],
                  );
                  if (result != null) {
                    File file = File(result.files.single.path!);
                    HMFeedback.showLoadingScreen(context);
                    await displayOTRContents(file.path);
                    Navigator.pop(context);
                  }
                } else if (_selectedIndex == 1) {
                  if (outputMPQ == null) {
                    outputMPQ = await FilePicker.platform.saveFile(
                        fileName: "Demo.mpq",
                        allowedExtensions: ['mpq', 'otr'],
                        type: FileType.custom,
                        dialogTitle: "Save Demo MPQ");
                    if (outputMPQ == null) return;
                    File file = File(outputMPQ!);
                    if (file.existsSync()) {
                      file.deleteSync();
                    }
                    mpqArchive = MPQArchive.create(outputMPQ!,
                        MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V4, 1024);
                  } else {
                    HMFeedback.showLoadingScreen(context);
                    for (String file in _outFiles) {
                      await writeDemoFile(outputMPQ!, file);
                    }
                    mpqArchive?.close();
                    _outFiles.clear();
                    outputMPQ = null;
                    Navigator.pop(context);

                    // HMFeedback.showCustomDialog(context)
                  }

                  setState(() {});
                }
              },
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => RotationTransition(
                        turns: child.key == const ValueKey('icon1')
                            ? Tween<double>(begin: 0.75, end: 1).animate(anim)
                            : Tween<double>(begin: 0.75, end: 1).animate(anim),
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                  child: Icon(
                      [
                        Icons.file_open_outlined,
                        outputMPQ == null ? Icons.create_new_folder : Icons.save
                      ][_selectedIndex],
                      key: ValueKey("icon$_selectedIndex"))),
            ),
      appBar: AppBar(
        title: const Text('Demo MPQ Utility',
            style: TextStyle(color: Colors.black54)),
        backgroundColor: Colors.orange[200],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black54,
          unselectedLabelColor: Colors.black26,
          tabs: [
            defaultTab("Open MPQ", Icons.file_open),
            defaultTab("Create MPQ", Icons.add),
            defaultTab("About", Icons.star_rounded),
          ],
        ),
      ),
      body: Center(
        child: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          dragStartBehavior: DragStartBehavior.down,
          children: [
            ListView.builder(
              itemCount: _otrFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_otrFiles[index]),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    if (outputMPQ == null)
                      const Center(
                          child: Text("Please select a path to save the mpq",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600))),
                    ..._outFiles.map((e) => Text(e)).toList(),
                    if (outputMPQ != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (outputMPQ == null) return;
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                _outFiles.add(result.files.single.path!);
                              });
                            }
                          },
                          child: const Text("Add File"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text("About:"),
                  const Text(
                      "This is a demo app for the flutter_storm package, which is a Dart wrapper for the StormLib library",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const Text("Flutter Storm Version:"),
                  Text("v${packageInfo.version}",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const Text("StormLib Version:"),
                  Text(STORMLIB_VERSION,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const Text("StormLib License:"),
                  const Text("MIT License",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const Text("StormLib Source:"),
                  InkWell(
                      onTap: () async {
                        _launchUrl(STORMLIB_REPO);
                      },
                      child: Text(STORMLIB_REPO,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600))),
                  // Simple about page
                  const Expanded(child: SizedBox()),
                  Center(
                    child: RichText(
                        text: TextSpan(children: [
                      const TextSpan(
                          text: "Made with ❤️ by the ",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      TextSpan(
                        text: "HarbourMasters",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchUrl('https://discord.gg/shipofharkinian');
                          },
                      ),
                      const TextSpan(
                          text: " Team",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black))
                    ])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
