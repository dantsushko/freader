import 'package:xml/xml.dart';

final xmlString = '''
           <section>
            <p>Потом я подумал, что он не может меня слышать. То есть он смог бы, если бы
                попробовал, но он не хотел пробовать. Я знал, что, если я снова заговорю с ним так,
                он <emphasis>толкнет</emphasis> меня. Он не разрешает мне общаться таким образом с
                Ночным Волком. Он даже <emphasis>толкает</emphasis> Ночного Волка, если тот слишком
                много разговаривает со мной. Это кажется очень странным.</p>
            <p>– Ночной Волк ждет, – сказал я вслух.</p>
            </section>
''';

void main() {
  final document = XmlDocument.parse(xmlString);

  for(final p in document.findAllElements('p')) {
    for(final child in p.children) {
      if(child is XmlText) {
        print(child.text);
      }else{
print(child.innerText);
      }
      // if(child is XmlElement && child.name.local == 'emphasis') {
        
      // }
    }
  }
}
