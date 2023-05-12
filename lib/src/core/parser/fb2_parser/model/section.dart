import 'package:xml/xml.dart';

class FB2Section {
  FB2Section(this.content) {
    final lengths = content.findAllElements('p').map((e) => e.innerText.split(' ').length);
    if(lengths.isNotEmpty){
      wordCount = lengths.reduce((value, element) => value + element);
    }else{
      wordCount = 0;
    }
  }
  late final int wordCount;
  final XmlElement content;
}
