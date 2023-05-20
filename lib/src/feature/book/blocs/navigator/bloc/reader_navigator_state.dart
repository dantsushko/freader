part of 'reader_navigator_bloc.dart';

@freezed
class ReaderNavigatorState with _$ReaderNavigatorState {
  const factory ReaderNavigatorState({
    required int chapterIndex,
    required int position,
  }) = _ReaderNavigatorState;
}
