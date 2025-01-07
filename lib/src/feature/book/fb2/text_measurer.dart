import 'package:flutter/widgets.dart';

class TextMeasurer {
  static final Map<String, Size> _sizeCache = {};
  
  static Size measureText(
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final key = '$text-${style.fontSize}-$maxWidth';
    if (_sizeCache.containsKey(key)) {
      return _sizeCache[key]!;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final size = Size(textPainter.width, textPainter.height);
    _sizeCache[key] = size;
    textPainter.dispose();
    
    return size;
  }

  static List<String> splitTextIntoPages(
    String text,
    TextStyle style,
    Size pageSize,
  ) {
    final words = text.split(' ');
    final pages = <String>[];
    String currentPage = '';
    String currentLine = '';
    
    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      final size = measureText(testLine, style, pageSize.width);
      
      if (size.width <= pageSize.width) {
        currentLine = testLine;
      } else {
        if (currentPage.isNotEmpty) currentPage += '\n';
        currentPage += currentLine;
        currentLine = word;
        
        final pageHeight = measureText(currentPage, style, pageSize.width).height;
        if (pageHeight > pageSize.height) {
          pages.add(currentPage);
          currentPage = '';
        }
      }
    }
    
    if (currentLine.isNotEmpty) {
      if (currentPage.isNotEmpty) currentPage += '\n';
      currentPage += currentLine;
    }
    
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }
    
    return pages;
  }

  static void clearCache() {
    _sizeCache.clear();
  }
}