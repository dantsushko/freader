part of 'reader_navigator_bloc.dart';

@freezed
class ReaderNavigatorEvent with _$ReaderNavigatorEvent {
  const factory ReaderNavigatorEvent.goToChapter(int chapterIndex) = _GoToChapter;
}