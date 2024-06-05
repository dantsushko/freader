import '../fb2_parser/model/author.dart';

class Author {
  Author.fromFB2Author(FB2Author author)
      : name = author.firstName,
        secondName = author.middleName,
        lastName = author.lastName,
        nameKey =
            '${author.lastName ?? ''} ${author.firstName ?? ''} ${author.middleName}';

  final String nameKey;
  final String? name;
  final String? secondName;
  final String? lastName;
}
