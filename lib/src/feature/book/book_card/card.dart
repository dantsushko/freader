export 'large_card.dart';
export 'medium_card.dart';
export 'small_card.dart';

enum BookCardType {
  small('Малые карточки'),
  medium('Карточки'),
  large('Большие карточки');
  const BookCardType(this.label);
  final String label;

}
