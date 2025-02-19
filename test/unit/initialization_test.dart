import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freader/src/core/router/router.dart';
import 'package:freader/src/feature/initialization/logic/initialization_processor.dart';
import 'package:freader/src/feature/initialization/logic/initialization_steps.dart';
import 'package:freader/src/feature/initialization/model/initialization_hook.dart';

void main() {
  group('Initialization Processor >', () {
    test('processInitialization should correctly work', () async {
      const processor = _TestInitializationProcessor();
      final result = await processor.processInitialization(
        steps: <String, StepAction>{
          'Init Shared Preferences': (progress) async {
            SharedPreferences.setMockInitialValues({});
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
          }
        },
        factory: const _TestInitializationFactory(),
        hook: InitializationHook.setup(),
      );
      expect(result, isNotNull);
      expect(result.stepCount, 2);
    });

    test('processInitialization should fail', () {
      const processor = _TestInitializationProcessor();
      expect(
        () => processor.processInitialization(
          steps: <String, StepAction>{
            'Init Shared Preferences': (progress) async {
              throw Exception();
            },
            'Init Router': (progress) {
              final router = AppRouter();
              return progress.copyWith(
                router: router,
              );
            }
          },
          factory: const _TestInitializationFactory(),
          hook: InitializationHook.setup(),
        ),
        throwsException,
      );
    });
  });
}

class _TestInitializationFactory = Object with InitializationFactoryImpl;

class _TestInitializationProcessor = Object with InitializationProcessor;
