import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ladder_assist/app_button.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_entry.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '梯子辅助',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<String> apkCachePath() async {
  var sdRoot = (await ExternalPath.getExternalStorageDirectories())[0];
  var path = '$sdRoot/ladder-assist';
  var pathDir = Directory(path);
  try {
    await pathDir.create(recursive: true);
  } catch (e) {}
  return '$path/cache.apk';
}

Future<void> deleteApkFiles() async {
  try {
    await File(await apkCachePath()).delete();
  } catch (e) {}
}

Future<void> requestPermission(Permission permission) async {
  await permission.request();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<AppEntry>> _loadAppEntries() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    await Permission.requestInstallPackages.request();
    await deleteApkFiles();
    try {
      var r = Random();
      final response = await http.get(
          Uri.parse('https://fhlclimb.work/data.json?${r.nextInt(1000000)}'));
      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((dynamic item) {
            String friendlyName = item['friendlyName'] ?? '';
            String packageName = item['packageName'] ?? '';
            int latestVersion = item['latestVersion'] ?? 0;
            String updatePath = item['updatePath'] ?? '';
            return AppEntry(
                friendlyName, packageName, latestVersion, updatePath);
          }).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('出错了'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: const Text('关闭'),
                onPressed: () {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("🪜梯子辅助"),
        ),
        body: FutureBuilder<List<AppEntry>>(
            future: _loadAppEntries(),
            builder:
                (BuildContext context, AsyncSnapshot<List<AppEntry>> snapshot) {
              final entries = snapshot.data;
              List<Widget> content;
              if (entries == null) {
                content = [const Text('加载中')];
              } else if (entries.isEmpty) {
                content = [const Text('加载失败')];
              } else {
                content = entries.map((e) => AppButton(appEntry: e)).toList();
              }
              List<Widget> finalContent = [];
              for (int i = 0; i < content.length; i++) {
                finalContent.add(content[i]);
                if (i < content.length - 1) {
                  finalContent.add(const SizedBox(
                    height: 25,
                  ));
                }
              }
              return Center(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: finalContent)));
            }));
  }
}
