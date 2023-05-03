import 'dart:async';

import 'package:freader/src/core/data/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freader/src/core/router/router.dart';
import 'package:freader/src/feature/initialization/model/initialization_progress.dart';

typedef StepAction = FutureOr<InitializationProgress>? Function(
  InitializationProgress progress,
);
mixin InitializationSteps {
  final initializationSteps = <String, StepAction>{
    ..._dependencies,
    ..._data,
  };
  static final _dependencies = <String, StepAction>{
    'Init Shared Preferences': (progress) async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return progress.copyWith(
        preferences: sharedPreferences,
      );
    },
    'Init Router': (progress) {
      final router = AppRouter();
      return progress.copyWith(
        router: router,
      );
    },
        'Init Database': (progress) async{
      final database =  AppDatabase();
      return progress.copyWith(
        database: database,
      );
    }
  };
  static final _data = <String, StepAction>{};
}
