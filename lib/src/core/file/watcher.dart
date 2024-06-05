import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freader/src/core/constants/constants.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:l/l.dart';
import 'package:watcher/watcher.dart';

import '../utils/path.dart';

List<String> dirsToWatch = [
  downloadDirPath,
  inboxDirPath,
];

class FileWatcher {
  FileWatcher(this.db) {
    for (final dir in dirsToWatch) {
      subscriptions.add(
        Watcher(dir, pollingDelay: const Duration(seconds: 3))
            .events
            .listen((event) => onEvent(event, dir)),
      );
    }
  }

  Future<void> init() async {
    for (final dir in dirsToWatch) {
      for (final d in Directory(dir).listSync()) {
        if (isBook(d.path)) {
          final relativePath = getRelativeBookPath(d.path, getDirName(dir));
          print('relativePath: $relativePath');
          final exists = await db.bookDao.bookExists(relativePath);
          l.i('check book: exists $exists');
          if (!exists) {
            final metadata = await compute(Parser().parseMetadata, d.path);

            // final book = await compute(Parser().parse, d.path);
            if (metadata != null) {
              await db.bookDao.importBook(metadata, relativePath, d.statSync().size);
            } else {
              File(d.path).deleteSync();
            }
          }
        }
      }
    }
  }

  Future<void> onEvent(WatchEvent event, String dir) async {
    if (event.type == ChangeType.ADD) {
      if (isBook(event.path)) {
        l.i('parsing metadata...');
        final metadata = await compute(Parser().parseMetadata, event.path);
        l.i('parsed metadata');
        if (metadata != null) {
          await db.bookDao.importBook(metadata, getRelativeBookPath(event.path, getDirName(dir)), File(event.path).lengthSync());
        } else {
          File(event.path).deleteSync();
        }
      }
    }
    // if (event.type == ChangeType.REMOVE) {
    //   if (isBook(event.path)) {
    //     await db.bookDao.deleteBook(event.path);
    //   }
    // }
  }

  final AppDatabase db;
  List<StreamSubscription<WatchEvent>> subscriptions = [];

  void dispose() {
    for (final sub in subscriptions) {
      sub.cancel();
    }
  }
}
