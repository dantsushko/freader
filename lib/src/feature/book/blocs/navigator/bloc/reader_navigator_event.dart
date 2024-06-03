part of 'reader_navigator_bloc.dart';

@freezed
class ReaderNavigatorEvent with _$ReaderNavigatorEvent {
  const factory ReaderNavigatorEvent.goToChapter(int chapterIndex) = _GoToChapter;
  const factory ReaderNavigatorEvent.updatePosition({int? page, int? scrollPosition, int? totalPages}) = _UpdatePosition;
}