import 'package:freader/runner_shared.dart';
import 'package:freader/src/feature/initialization/model/initialization_hook.dart';

// Web runner
Future<void> run() async {
  // there could be some web specific initialization here
  sharedRun(
    InitializationHook.setup(),
  );
}
