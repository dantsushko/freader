import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:freader/src/core/data/database/daos/settings_dao.dart';
import 'package:freader/src/core/parser/fb2_parser/model/element.dart';
import 'package:freader/src/core/parser/fb2_parser/fb2_parser.dart';

class PageSize {
  final double width;
  final double height;

  const PageSize({required this.width, required this.height});
}

class RenderedElement {
  final Widget widget;
  final double height;

  const RenderedElement({required this.widget, required this.height});
}

class FB2PageRenderer {
  static Future<List<Widget>> renderPages(
    FB2Book book,
    BuildContext context,
    SettingsModel settings,
  ) async {
    final pageSize = _calculatePageSize(context, settings);
    
    final chunks = _splitIntoChunks(book.elements);
    
    final processedChunks = await Future.wait(
      chunks.map((chunk) => compute(_processChunk, {
        'chunk': chunk,
        'pageSize': pageSize,
        'settings': settings,
      })),
    );

    return _combineChunks(processedChunks, context, settings);
  }

  static PageSize _calculatePageSize(BuildContext context, SettingsModel settings) {
    final mediaQuery = MediaQuery.of(context);
    final paddingTop = mediaQuery.padding.top;
    final paddingBottom = mediaQuery.padding.bottom;
    
    return PageSize(
      height: mediaQuery.size.height - paddingTop - paddingBottom - 
             settings.pageTopPadding - settings.pageBottomPadding,
      width: mediaQuery.size.width - settings.pageHorizontalPadding * 2,
    );
  }

  static List<List<FB2Element>> _splitIntoChunks(List<FB2Element> elements) {
    const chunkSize = 100;
    final chunks = <List<FB2Element>>[];
    
    for (var i = 0; i < elements.length; i += chunkSize) {
      chunks.add(elements.sublist(
        i, 
        i + chunkSize < elements.length ? i + chunkSize : elements.length,
      ));
    }
    
    return chunks;
  }

  static List<Widget> _combineChunks(
    List<List<RenderedElement>> chunks,
    BuildContext context,
    SettingsModel settings,
  ) {
    final pages = <Widget>[];
    var currentPageElements = <Widget>[];
    var currentPageHeight = 0.0;
    final pageSize = _calculatePageSize(context, settings);

    for (final chunk in chunks) {
      for (final element in chunk) {
        if (currentPageHeight + element.height > pageSize.height) {
          pages.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.from(currentPageElements),
          ));
          currentPageElements = [element.widget];
          currentPageHeight = element.height;
        } else {
          currentPageElements.add(element.widget);
          currentPageHeight += element.height;
        }
      }
    }

    if (currentPageElements.isNotEmpty) {
      pages.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.from(currentPageElements),
      ));
    }

    return pages;
  }
}

Future<List<RenderedElement>> _processChunk(Map<String, dynamic> params) async {
  final chunk = params['chunk'] as List<FB2Element>;
  final pageSize = params['pageSize'] as PageSize;
  final settings = params['settings'] as SettingsModel;
  
  final renderedElements = <RenderedElement>[];
  
  for (final element in chunk) {
    final rendered = await _renderElement(element, pageSize.width, settings);
    renderedElements.add(rendered);
  }
  
  return renderedElements;
}

Future<RenderedElement> _renderElement(
  FB2Element element,
  double width,
  SettingsModel settings,
) async {
  if (element is FB2EmptyLine) {
    return RenderedElement(
      widget: const SizedBox(height: 16),
      height: 16,
    );
  }

  if (element is FB2Image) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(element.bytes, completer.complete);
    final image = await completer.future;
    return RenderedElement(
      widget: Image.memory(element.bytes),
      height: image.height.toDouble(),
    );
  }

  final textStyle = _getTextStyle(element, settings);
  final textPainter = TextPainter(
    text: TextSpan(text: element.text, style: textStyle),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.justify,
  )..layout(maxWidth: width);

  final widget = Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      element.text,
      style: textStyle,
      textAlign: TextAlign.justify,
    ),
  );

  return RenderedElement(
    widget: widget,
    height: textPainter.height + 8, // Adding padding
  );
}

TextStyle _getTextStyle(FB2Element element, SettingsModel settings) {
  final fontSize = element is FB2Subtitle
      ? settings.fontSize + 2
      : element is FB2Title
          ? settings.fontSize + 4
          : settings.fontSize.toDouble();

  return TextStyle(
    wordSpacing: 4,
    letterSpacing: settings.letterSpacing,
    fontStyle: FontStyle.normal,
    fontWeight:
        element is FB2Subtitle || element is FB2Title ? FontWeight.bold : FontWeight.normal,
    fontSize: fontSize,
  );
}