import 'dart:async';
import 'dart:io';

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
  Future<void> onEvent(WatchEvent event, String dir) async {
    l.i(event);
    if (event.type == ChangeType.ADD) {
      if (isBook(event.path)) {
        final parsedBook = await Parser().parse(event.path);
        if (parsedBook != null) {
          l.i('importing book');
          await db.bookDao.importBook(parsedBook);
        } else {
          File(event.path).deleteSync();
        }
      }
    }
    if (event.type == ChangeType.REMOVE) {
      if (isBook(event.path)) {
        print('delete book');
        await db.bookDao.deleteBook(getFileName(event.path));
      }
    }
  }

  FileWatcher(this.db) {
    for (final dir in dirsToWatch) {
      subscriptions.add(Watcher(dir, pollingDelay: const Duration(seconds: 3))
          .events
          .listen((event) => onEvent(event, dir)));
    }
  }
  final AppDatabase db;
  List<StreamSubscription<WatchEvent>> subscriptions = [];

  void dispose() {
    for (final sub in subscriptions) {
      sub.cancel();
    }
  }
}
