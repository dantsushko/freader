import 'package:xml/xml.dart';

class FB2Author {
  /// author's first name
  late final String? firstName;

  /// author's middle name
  late final String? middleName;

  /// author's last name
  late final String? lastName;

  /// author's nickname
  late final String? nickname;

  /// author's email
  late final String? email;

  FB2Author(XmlElement author) {
    firstName = author.getElement('first-name')?.innerText;
    middleName = author.getElement('middle-name')?.innerText;
    lastName = author.getElement('last-name')?.innerText;
    nickname = author.getElement('nickname')?.innerText;
    email = author.getElement('email')?.innerText;
    
  }

  @override
  String toString() {
    return 'FB2Author(firstName: $firstName, middleName: $middleName, lastName: $lastName, nickname: $nickname, email: $email)';
  }
}
