import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reader_navigator_event.dart';
part 'reader_navigator_state.dart';
part 'reader_navigator_bloc.freezed.dart';

class ReaderNavigatorBloc extends Bloc<ReaderNavigatorEvent, ReaderNavigatorState> {
  ReaderNavigatorBloc() : super(const ReaderNavigatorState(chapterIndex: 0, scrollPosition: 0, page: 0, totalPages: 0)) {
    on<ReaderNavigatorEvent>((event, emit) {
      event.map(
        updatePosition: (e) {
          emit(state.copyWith(page: e.page ?? state.page, scrollPosition: e.scrollPosition ?? state.scrollPosition, totalPages: e.totalPages ?? state.totalPages));
        },
        goToChapter: (e) {
          emit(state.copyWith(chapterIndex: e.chapterIndex));
        },
      );
    });
   
  }
}
