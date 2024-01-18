import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:freader/runner_shared.dart';
import 'package:freader/src/feature/initialization/model/initialization_hook.dart';

Future<void> run() async {

  sharedRun(
    InitializationHook.setup(),
  );
}
