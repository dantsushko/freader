import 'dart:collection';

import 'hyphenator.dart';

class HyphenUtils {
  static const String shy = '\u{00AD}';
  static Map<String, String> cache = HashMap<String, String>();
  static bool ignore = false;
  static bool ignore1 = false;
  static Hyphenator instance = Hyphenator(HyphenPattern.error);
  static void applyLanguage(String? lang) {
    if (lang == null) {
      return;
    }
    try {
      if (lang.length > 2) {
        lang = lang.substring(0, 2).toLowerCase();
      }
      if (lang == 'sp') {
        lang = 'es';
      }

      var pattern = HyphenPattern.error;
      for (final p in HyphenPattern.values) {
        if (p.lang == lang) {
          pattern = p;
        }
      }

      if (instance.pattern != pattern) {
        instance = Hyphenator(pattern);
        cache.clear();
      }
    } catch (e) {
      print('Error: $e');
      instance = Hyphenator(HyphenPattern.error);
    }
    print('My-pattern-lang: ${instance.pattern.lang}');
  }
}
