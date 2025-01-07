import 'dart:collection';
import 'package:flutter/widgets.dart';

class PageCache {
  static const int maxCachedPages = 50;
  final Map<String, List<Widget>> _cache = {};
  final Queue<String> _cacheOrder = Queue();

  void add(String key, List<Widget> pages) {
    if (_cache.length >= maxCachedPages) {
      final oldestKey = _cacheOrder.removeFirst();
      _cache.remove(oldestKey);
    }
    _cache[key] = pages;
    _cacheOrder.addLast(key);
  }

  List<Widget>? get(String key) => _cache[key];

  void clear() {
    _cache.clear();
    _cacheOrder.clear();
  }
}