import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ladder_assist/app_button.dart';

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

Future<List<AppEntry>> _loadAppEntries() async {
  try {
    final response =
        await http.get(Uri.parse('https://fhlclimb.work/data.json'));
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      if (data is List) {
        return data.map((dynamic item) {
          String friendlyName = item['friendlyName'] ?? '';
          String packageName = item['packageName'] ?? '';
          int latestVersionCode = item['latestVersionCode'] ?? 0;
          String updatePath = item['updatePath'] ?? '';
          return AppEntry(
              friendlyName, packageName, latestVersionCode, updatePath);
        }).toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
