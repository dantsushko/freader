import 'package:flutter/widgets.dart';

extension LocalizationX on BuildContext {
  T stringOf<T>() => Localizations.of<T>(this, T)!;
}


extension IntX on int{
  String get prettyBytes {
    if (this < 1024) {
      return '$this B';
    } else if (this < 1024 * 1024) {
      final kb = this / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (this < 1024 * 1024 * 1024) {
      final mb = this / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      final gb = this / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }
}
