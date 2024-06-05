import 'package:xml/xml.dart';

class FB2Book {
  final XmlDocument document;
  final double pageWidth;
  final double pageHeight;
  final double fontSize;
  final double wordSpace;
  final double letterSpace;

  FB2Book(
    this.document, {
    required this.pageWidth,
    required this.pageHeight,
    required this.fontSize,
    required this.wordSpace,
    required this.letterSpace,
  });

  List<List<XmlNode>> paginate() {
    List<List<XmlNode>> pages = [];
    List<XmlNode> currentPage = [];

    double currentHeight = 0.0;

    for (var element in document.rootElement.descendants) {
      double elementHeight = _calculateElementHeight(element);

      if (currentHeight + elementHeight > pageHeight) {
        pages.add(currentPage);
        currentPage = [];
        currentHeight = 0.0;
      }

      currentPage.add(element);
      currentHeight += elementHeight;
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    return pages;
  }

  double _calculateElementHeight(XmlNode element) {
    if (element is XmlElement) {
      switch (element.name.local) {
        case 'image':
          return _calculateImageHeight(element);
        case 'title':
        case 'subtitle':
          return fontSize * 2; // Adjust based on your title/subtitle font size
        case 'p':
          return _calculateParagraphHeight(element);
        default:
          return _calculateTextHeight(element);
      }
    }
    return 0.0;
  }

  double _calculateImageHeight(XmlElement element) {
    // Calculate image height based on image dimensions and aspect ratio
    // Placeholder value
    return 100.0;
  }

  double _calculateParagraphHeight(XmlElement element) {
    String text = element.text;
    return _calculateTextHeightForWidth(text, pageWidth);
  }

  double _calculateTextHeight(XmlNode element) {
    if (element is XmlText) {
      return _calculateTextHeightForWidth(element.text, pageWidth);
    }
    return fontSize; // Default height for non-text elements
  }

  double _calculateTextHeightForWidth(String text, double width) {
    int charPerLine = ((width - letterSpace) / (fontSize / 2 + letterSpace)).floor();
    int lineCount = (text.length / charPerLine).ceil();

    // Calculate the height based on the number of lines
    double lineHeight = fontSize * 1.2; // Adjust line height as needed
    return lineCount * lineHeight;
  }
}

void main() {
  final fb2Xml = '''<FictionBook>
    <body>
      <section>
        <title>Chapter 1</title>
        <subtitle>Introduction</subtitle>
        <p>This is a sample paragraph with some <strong>bold text</strong> and <em>italic text</em>.</p>
        <image href="image1.png"/>
      </section>
    </body>
  </FictionBook>''';

  final document = XmlDocument.parse(fb2Xml);

  FB2Book book = FB2Book(
    document,
    pageWidth: 100.0,
    pageHeight: 800.0,
    fontSize: 14.0,
    wordSpace: 4.0,
    letterSpace: 1.0,
  );

  List<List<XmlNode>> pages = book.paginate();

  for (int i = 0; i < pages.length; i++) {
    print('Page ${i + 1}');
    for (var node in pages[i]) {
      print(node);
    }
  }
}
