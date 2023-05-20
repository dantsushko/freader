import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freader/src/core/parser/parser.dart';
import 'package:freader/src/feature/book/blocs/navigator/bloc/reader_navigator_bloc.dart';
import 'package:freader/src/feature/book/settings/book_settings_screen.dart';
import 'package:freader/src/feature/book/toc/toc_screen.dart';
import 'package:go_router/go_router.dart';

class FloatingAppBar extends StatelessWidget {
  const FloatingAppBar({
    required this.title,
    required this.showControls,
    required this.book,
    super.key,
  });
  final String title;
  final ValueNotifier<bool> showControls;
  final CommonBook? book;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: showControls,
        builder: (ctx, show, child) {
          if (!show) return const SizedBox.shrink();
          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 30,
            child: AppBar(
              title: Text(
                title,
              ),
              leading: InkWell(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.close,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () => showModalBottomSheet<void>(
                    isScrollControlled: true,
                    context: context,
                    builder: (ctx) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: const BookSettingsScren(),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet<void>(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: BlocProvider.value(
                          value:context.read<ReaderNavigatorBloc>(),
                          child: TocScreen(
                            toc: book?.toc,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.menu_book_sharp,
                  ),
                ),
              ],
            ),
          );
        },
      );
}
