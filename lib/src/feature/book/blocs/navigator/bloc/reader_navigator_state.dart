part of 'reader_navigator_bloc.dart';

@freezed
class ReaderNavigatorState with _$ReaderNavigatorState {
  const factory ReaderNavigatorState({
    required int chapterIndex,
    required int page,
    required int scrollPosition,
    required int totalPages,
  }) = _ReaderNavigatorState;
}
