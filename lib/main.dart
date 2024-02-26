import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ladder_assist/app_button.dart';
import 'package:path_provider/path_provider.dart';
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

Future<void> deleteApkFiles() async {
  try {
    var externalDirectory = await getExternalStorageDirectory();
    if (externalDirectory == null) {
      throw Exception('Could not get external directory.');
    }
    List<FileSystemEntity> files = externalDirectory.listSync();
    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.apk')) {
        await file.delete();
        print('Deleted APK file: ${file.path}');
      }
    }
  } catch (e) {}
}

Future<void> requestPermission(Permission permission) async {
  await permission.request();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<AppEntry>> _loadAppEntries() async {
    await requestPermission(Permission.storage);
    await requestPermission(Permission.manageExternalStorage);
    await requestPermission(Permission.requestInstallPackages);
    await deleteApkFiles();
    try {
      final response =
          await http.get(Uri.parse('https://fhlclimb.work/data.json'));
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
