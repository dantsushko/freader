import 'package:xml/xml.dart';

class FB2Author {

  FB2Author(XmlElement author) {
    firstName = author.getElement('first-name')?.innerText;
    middleName = author.getElement('middle-name')?.innerText;
    lastName = author.getElement('last-name')?.innerText;
    nickname = author.getElement('nickname')?.innerText;
    email = author.getElement('email')?.innerText;
    
  }
  late final String? firstName;
  late final String? middleName;
  late final String? lastName;
  late final String? nickname;
  late final String? email;
  @override
  String toString() => 'FB2Author(firstName: $firstName, middleName: $middleName, lastName: $lastName, nickname: $nickname, email: $email)';
}
