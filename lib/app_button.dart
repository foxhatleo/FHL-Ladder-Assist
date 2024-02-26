import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:path_provider/path_provider.dart';

import 'app_entry.dart';

class AppButton extends StatefulWidget {
  final AppEntry appEntry;

  const AppButton({super.key, required this.appEntry});

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum AppState { notInstalled, updateAvailable, installed }

class _AppButtonState extends State<AppButton> {
  AppState _state = AppState.notInstalled;
  late Timer _timer;
  int _currentVersion = -1;

  @override
  void initState() {
    super.initState();
    _refreshState();
    _timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => _refreshState());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _refreshState() async {
    AppState newState = AppState.notInstalled;
    int version = -1;
    try {
      var info = await InstalledApps.getAppInfo(widget.appEntry.packageName);
      if (info.versionCode! < widget.appEntry.latestVersion) {
        newState = AppState.updateAvailable;
      } else {
        newState = AppState.installed;
      }
      version = info.versionCode!;
    } catch (e) {}
    if (_currentVersion != version || _state != newState) {
      setState(() {
        _state = newState;
        _currentVersion = version;
      });
    }
  }

  Future<File> _copyFileToExternalStorage(File sourceFile) async {
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw Exception("External storage directory not found");
    }
    File destinationFile = File('${externalDir.path}/ladder-assist-cache.apk');
    await sourceFile.copy(destinationFile.path);
    await sourceFile.delete();
    return destinationFile;;
  }

  void _install() async {
    var appDocDir = await getExternalStorageDirectory();
    if (appDocDir == null) {
      throw Exception('Could not get external directory.');
    }
    String savePath =
        "${appDocDir.path}/${widget.appEntry.friendlyName}_${widget.appEntry.latestVersion}.apk";
    if (!mounted) return;
    StateSetter? setDialogState;
    double progress = 0.0;
    final cancelToken = CancelToken();
    showDialog(
      context: context,
      builder: (BuildContext context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('下载中'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                setDialogState = setState;
                return LinearProgressIndicator(value: progress);
              },
            ),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  cancelToken.cancel();
                },
              ),
            ],
          )),
      barrierDismissible: false,
    );
    try {
      await Dio().download(
          "https://fhlclimb.work/apk/${widget.appEntry.updatePath}", savePath,
          cancelToken: cancelToken, onReceiveProgress: (count, total) {
        final value = count / total;
        if (setDialogState != null) {
          setDialogState!(() {
            progress = value;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!cancelToken.isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("下载出错。请联系Leo。"),
        ));
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    await InstallPlugin.install(savePath);
    _refreshState();
    try {
      File(savePath).delete();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 60.0,
        maxWidth: 400.0,
      ),
      child: SizedBox(
        width: double.infinity,
        child: _state == AppState.installed
            ? FilledButton.tonal(
                onPressed: _install,
                child: Text("${widget.appEntry.friendlyName} 已是最新版"),
              )
            : FilledButton(
                onPressed: _install,
                child: Text("${widget.appEntry.friendlyName} 有更新"),
              ),
      ),
    );
  }
}
