import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reader_navigator_event.dart';
part 'reader_navigator_state.dart';
part 'reader_navigator_bloc.freezed.dart';

class ReaderNavigatorBloc extends Bloc<ReaderNavigatorEvent, ReaderNavigatorState> {
  final CommonBook book;
  ReaderNavigatorBloc(this.book) : super(ReaderNavigatorState(chapterIndex: 0, position: 0)) {
    
     if (book.toc != null) {
      for (final chapter in book.toc!.chapters) {
        chapterKeys[chapter.title] = GlobalKey();
      }
    }
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
