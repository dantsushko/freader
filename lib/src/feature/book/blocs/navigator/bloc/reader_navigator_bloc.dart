import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reader_navigator_event.dart';
part 'reader_navigator_state.dart';
part 'reader_navigator_bloc.freezed.dart';

class ReaderNavigatorBloc extends Bloc<ReaderNavigatorEvent, ReaderNavigatorState> {
  ReaderNavigatorBloc() : super(const ReaderNavigatorState(chapterIndex: 0, position: 0)) {
    on<ReaderNavigatorEvent>((event, emit) {
      event.map(
        goToChapter: (e) {
          emit(state.copyWith(chapterIndex: e.chapterIndex));
        },
      );
    });
   
  }
  Map<String, GlobalKey> chapterKeys = {};
}
