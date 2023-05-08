import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/file/watcher.dart';
import 'package:freader/src/core/utils/downloader.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freader/src/core/router/router.dart';

part 'initialization_progress.freezed.dart';

@freezed
class RepositoriesStore with _$RepositoriesStore {
  const factory RepositoriesStore() = _RepositoriesStore;
}

@freezed
class DependenciesStore with _$DependenciesStore {
  const factory DependenciesStore({
    required SharedPreferences preferences,
    required AppRouter router,
    required AppDatabase database,
    required  Downloader downloader,
    required FileWatcher fileWatcher,
  }) = _DependenciesStore;

  const DependenciesStore._();
}

@freezed
class InitializationProgress with _$InitializationProgress {
  const factory InitializationProgress({
    SharedPreferences? preferences,
    AppRouter? router,
    Downloader? downloader,
    AppDatabase? database,
    FileWatcher? fileWatcher,
  }) = _InitializationProgress;

  const InitializationProgress._();

  DependenciesStore dependencies() => DependenciesStore(
        preferences: preferences!,
        database: database!,
        downloader: downloader!,
        fileWatcher: fileWatcher!,
        router: router!,
      );

  RepositoriesStore repositories() => const RepositoriesStore();
}

@freezed
class InitializationResult with _$InitializationResult {
  const factory InitializationResult({
    required DependenciesStore dependencies,
    required RepositoriesStore repositories,
    required int stepCount,
    required int msSpent,
  }) = _InitializationResult;
}
