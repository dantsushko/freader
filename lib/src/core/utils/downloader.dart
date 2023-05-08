import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/utils/path.dart';
import 'package:l/l.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import '../constants/constants.dart';

enum DownloadState { none, queued, downloading, failed, cancelled, paused, downloaded }

class DownloadStatus {
  DownloadStatus(this.id, this.percentage, this.status);
  final String id;
  final int percentage;
  final DownloadState status;
}

class Downloader {
  Downloader(this.database);
  final AppDatabase database;

  final ReceivePort _port = ReceivePort();
  final downloadController = StreamController<DownloadStatus?>.broadcast();
  Stream<DownloadStatus?> get downloadProgress => downloadController.stream;
  late final StreamSubscription<List<SharedFile>> _intentDataStreamSubscription;
  late final StreamSubscription<dynamic> _portSubscription;

  void dispose() {
    _intentDataStreamSubscription.cancel();
    _portSubscription.cancel();
    downloadController.close();
  }

  Future<bool> requestStoragePermissions() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    final storageIsGranted = await Permission.storage.isGranted;
    final manageExternalStorageIsGranted = await Permission.manageExternalStorage.isGranted;

    final isGranted = storageIsGranted &&
        manageExternalStorageIsGranted;
    print(isGranted);
    return isGranted;
  }

  String? currentTaskId;
  List<SharedFile>? list;
  Future<void> init() async {
    downloadDirPath = await getDir([baseBookDirName, downloadDirName]);
    inboxDirPath = await getDir([baseBookDirName, inboxDirName]);
    baseBookDirPath = await getDir([baseBookDirName]);
    baseDirPath = await getDir();
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
    await FlutterDownloader.registerCallback(downloadCallback);
    await initSharing();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _portSubscription = _port.listen((data) {
      final taskId = (data as List)[0] as String;
      final status = DownloadTaskStatus(data[1] as int);
      final progress = data[2] as int;
      var state = DownloadState.none;

      if (status == DownloadTaskStatus.enqueued) {
        state = DownloadState.queued;
      } else if (status == DownloadTaskStatus.canceled) {
        state = DownloadState.cancelled;
      } else if (status == DownloadTaskStatus.complete) {
        state = DownloadState.downloaded;
      } else if (status == DownloadTaskStatus.running) {
        state = DownloadState.downloading;
      } else if (status == DownloadTaskStatus.failed) {
        state = DownloadState.failed;
      } else if (status == DownloadTaskStatus.paused) {
        state = DownloadState.paused;
      }
      if (state == DownloadState.downloaded) {}
      downloadController
          .add(progress != 100 && progress != -1 ? DownloadStatus(taskId, progress, state) : null);
    });
  }

  Future<void> startDownload(String url) async {
    if (await requestStoragePermissions()) {
      print(url);
      currentTaskId = await enqueTask(url);
    }
  }

  Future<void> cancelDownload() async {
    if (currentTaskId != null) {
      await FlutterDownloader.cancel(taskId: currentTaskId!);
    }
    currentTaskId = null;

    downloadController.add(null);
  }

  Future<String?> enqueTask(String url) async => FlutterDownloader.enqueue(
        url: url,
        savedDir: downloadDirPath,
        showNotification: false,
        openFileFromNotification: false,
      );
  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName(
      'downloader_send_port',
    )!
        .send([id, status.value, progress]);
  }

  Future<void> initSharing() async {
    void moveToInbox(List<SharedFile> sharedFiles) {
      print('MOVE TO INBOX');
      for (final sf in sharedFiles) {
        if (sf.value == null) continue;
        final file = File(sf.value!);
        final fileName = getFileName(sf.value!);
        final dest = path.join(inboxDirPath, fileName);
        file.copySync(dest);
      }
    }

    _intentDataStreamSubscription =
        FlutterSharingIntent.instance.getMediaStream().listen(moveToInbox, onError: l.e);
    final shared = await FlutterSharingIntent.instance.getInitialSharing();
    moveToInbox(shared);
  }
}
