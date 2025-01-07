import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freader/src/core/data/database/database.dart';
import 'package:freader/src/core/data/database/daos/settings_dao.dart';
import 'package:freader/src/core/parser/fb2_parser/fb2_parser.dart';
import 'package:freader/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:go_router/go_router.dart';

import '../blocs/navigator/bloc/reader_navigator_bloc.dart';
import '../floating_app_bar.dart';
import 'fb2_page_renderer.dart';
import 'page_cache.dart';
import 'text_measurer.dart';

class FB2Screen extends StatefulWidget {
  const FB2Screen({
    required this.book,
    required this.bid,
    super.key,
  });

  final FB2Book book;
  final int bid;

  @override
  State<FB2Screen> createState() => _FB2ScreenState();
}

class _FB2ScreenState extends State<FB2Screen> {
  late final PageCache _pageCache;
  late final PageController _pageController;
  late SettingsModel _settings;
  late final ReaderNavigatorBloc _readerNavigatorBloc;
  late final AppDatabase _database;
  
  List<Widget>? _currentPages;
  bool _isLoading = true;
  ValueNotifier<bool> showControls = ValueNotifier<bool>(false);
  Stopwatch _tapStopwatch = Stopwatch();
  Offset _tapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _pageCache = PageCache();
    _database = DependenciesScope.dependenciesOf(context).database;
    _settings = _database.settingsDao.initialSettings;
    _readerNavigatorBloc = context.read<ReaderNavigatorBloc>();
    _initializePages();
  }

  Future<void> _initializePages() async {
    setState(() => _isLoading = true);
    
    final cacheKey = _getCacheKey();
    _currentPages = _pageCache.get(cacheKey);
    
    if (_currentPages == null) {
      _currentPages = await FB2PageRenderer.renderPages(
        widget.book,
        context,
        _settings,
      );
      _pageCache.add(cacheKey, _currentPages!);
    }
    
    final cursor = await _database.cursorDao.getCursor(widget.bid);
    _pageController = PageController(initialPage: cursor?.page ?? 0);
    _readerNavigatorBloc.add(ReaderNavigatorEvent.updatePosition(
      totalPages: _currentPages!.length,
      page: cursor?.page ?? 0,
    ));
    
    setState(() => _isLoading = false);
  }

  String _getCacheKey() => '${widget.bid}_${_settings.fontSize}_'
    '${_settings.pageHorizontalPadding}_${_settings.pageTopPadding}_'
    '${_settings.pageBottomPadding}_${_settings.letterSpacing}_'
    '${_settings.softHyphen}';

  void _handleTap(PointerUpEvent details) {
    _tapStopwatch.stop();
    final ms = _tapStopwatch.elapsedMilliseconds;
    _tapStopwatch.reset();

    if (ms > 150 || _tapPosition != details.localPosition) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final tapPositionX = details.localPosition.dx;
    final tapPositionY = details.localPosition.dy;

    if (tapPositionX > screenWidth / 3 &&
        tapPositionX < (screenWidth / 3) * 2 &&
        tapPositionY > screenHeight / 3 &&
        tapPositionY < (screenHeight / 3) * 2) {
      showControls.value = !showControls.value;
      _updateSystemUI();
    }
  }

  void _updateSystemUI() {
    if (showControls.value) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
    }
  }

  void _handlePageChanged(int page) {
    _readerNavigatorBloc.add(ReaderNavigatorEvent.updatePosition(page: page));
    _database.cursorDao.updateCursor(bid: widget.bid, page: page);
    _preRenderNearbyPages(page);
  }

  Future<void> _preRenderNearbyPages(int currentPage) async {
    const pagesToPreRender = 3;
    for (var i = 1; i <= pagesToPreRender; i++) {
      final nextPage = currentPage + i;
      if (nextPage < _currentPages!.length) {
        compute(_preRenderPage, _currentPages![nextPage]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Listener(
      onPointerUp: _handleTap,
      onPointerDown: (details) {
        _tapPosition = details.localPosition;
        _tapStopwatch.start();
      },
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          left: false,
          right: false,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _currentPages!.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    left: _settings.pageHorizontalPadding,
                    right: _settings.pageHorizontalPadding,
                    top: _settings.pageTopPadding,
                    bottom: _settings.pageBottomPadding,
                  ),
                  child: _currentPages![index],
                ),
                onPageChanged: _handlePageChanged,
              ),
              FloatingAppBar(
                showControls: showControls,
                title: widget.book.title ?? '',
                book: widget.book,
              ),
              BottomBookBar(
                showControls: showControls,
                book: widget.book,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    TextMeasurer.clearCache();
    super.dispose();
  }
}

Future<void> _preRenderPage(Widget page) async {
  // Force layout calculation in the background
  await compute((Widget p) {
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    final element = SingleChildRenderObjectElement(p as RenderObjectWidget);
    element.mount(null, null);
    buildOwner.buildScope(element);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    return;
  }, page);
}

class BottomBookBar extends StatelessWidget {
  const BottomBookBar({
    required this.showControls,
    required this.book,
    super.key,
  });

  final ValueNotifier<bool> showControls;
  final FB2Book book;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: showControls,
    builder: (ctx, show, child) {
      if (!show) return const SizedBox.shrink();
      return BlocBuilder<ReaderNavigatorBloc, ReaderNavigatorState>(
        builder: (context, state) => Positioned(
          bottom: 0,
          height: 50,
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Current chapter'),
                  const Spacer(),
                  Text('${state.page + 1}/${state.totalPages}')
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}