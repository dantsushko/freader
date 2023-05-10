import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:background_downloader/background_downloader.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/utils/path.dart';
import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import '../constants/constants.dart';

enum DownloadState { none, queued, downloading, failed, cancelled, paused, downloaded }

class DownloadStatus {
  DownloadStatus(this.percentage, this.status);
  final double percentage;
  final DownloadState status;
}

class Downloader {
  Downloader(this.database);
  final AppDatabase database;

  final ReceivePort _port = ReceivePort();
  final downloadController = StreamController<DownloadStatus>.broadcast();
  Stream<DownloadStatus> get downloadProgress => downloadController.stream;
  late final StreamSubscription<List<SharedFile>> _intentDataStreamSubscription;
  late final StreamSubscription<dynamic> _portSubscription;

  void dispose() {
    _intentDataStreamSubscription.cancel();
    _portSubscription.cancel();
    downloadController.close();
  }

  String? currentTaskId;
  List<SharedFile>? list;
  Future<void> init() async {
    downloadDirPath = await getDir([baseBookDirName, downloadDirName]);
    inboxDirPath = await getDir([baseBookDirName, inboxDirName]);
    baseBookDirPath = await getDir([baseBookDirName]);
    baseDirPath = await getDir();
    await initSharing();
  }

  Future<String> getRedirectedUri(String url) async {
    final req = http.Request('GET', Uri.parse(url))..followRedirects = false;
    final baseClient = http.Client();
    final response = await baseClient.send(req);
    baseClient.close();
    return response.headers['location'] ?? url;
  }

  Future<void> startDownload(String url) async {
    downloadController.add(DownloadStatus(0, DownloadState.queued));
    final uri = await getRedirectedUri(url);
    final task = await DownloadTask(url: uri, directory: 'Books/Downloads')
        .withSuggestedFilename(unique: true);
    await FileDownloader().download(task, onProgress: (progress) {
      var state = DownloadState.none;
      if (progress == 1) {
        state = DownloadState.downloaded;
      } else {
        state = DownloadState.downloading;
      }
      downloadController.add(DownloadStatus(progress, state));
    });

    // }
  }

  Future<void> cancelDownload() async {
    // if (currentTaskId != null) {
    //   await FlutterDownloader.cancel(taskId: currentTaskId!);
    // }
    currentTaskId = null;

    downloadController.add(DownloadStatus(0, DownloadState.cancelled));
  }

  // Future<String?> enqueTask(String url) async => FlutterDownloader.enqueue(
  //       url: url,
  //       savedDir: downloadDirPath,
  //       showNotification: false,
  //       openFileFromNotification: false,
  //     );
  // @pragma('vm:entry-point')
  // static void downloadCallback(
  //   String id,
  //   DownloadTaskStatus status,
  //   int progress,
  // ) {
  //   IsolateNameServer.lookupPortByName(
  //     'downloader_send_port',
  //   )!
  //       .send([id, status.value, progress]);
  // }

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
