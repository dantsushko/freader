import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freader/src/core/parser/toc.dart';
import 'package:freader/src/feature/book/blocs/navigator/bloc/reader_navigator_bloc.dart';

class TocScreen extends StatefulWidget {
  const TocScreen({required this.toc, super.key});
  final TableOfContents? toc;
  @override
  State<TocScreen> createState() => _TocScreenState();
}

class _TocScreenState extends State<TocScreen> {
  @override
  Widget build(BuildContext context) => ListView(
        children: widget.toc?.chapters
                .map(
                  (e) => ListTile(
                    onTap: () => context
                        .read<ReaderNavigatorBloc>()
                        .add(ReaderNavigatorEvent.goToChapter(e.index)),
                    title: Text(e.title),
                  ),
                )
                .toList() ??
            [],
      );
}
