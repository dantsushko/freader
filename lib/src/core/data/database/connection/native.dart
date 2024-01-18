import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


Future<File> get databaseFile async {
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'freader.db');
  // if(kDebugMode){
  //   await File(dbPath).delete();
  // }
  return File(dbPath);
}

DatabaseConnection connect() =>
    DatabaseConnection.delayed(Future(() async => NativeDatabase.createBackgroundConnection(
          await databaseFile,
        ),),);

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  if (kDebugMode) {
    await VerifySelf(database).validateDatabaseSchema();
  }
}
