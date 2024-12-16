import 'dart:async';

import 'package:alex_k_test/src/features/presentation/widgets/general_container.dart';
import 'package:flutter/material.dart';

class BodyGradientFusion extends StatefulWidget {
  final Widget primaryView;
  final Widget secondaryView;
  final List<String> titles;

  const BodyGradientFusion(
      {super.key,
      required this.secondaryView,
      required this.primaryView,
      required this.titles});

  @override
  _BodyGradientFusionState createState() => _BodyGradientFusionState();
}

class _BodyGradientFusionState extends State<BodyGradientFusion> {
  final PageController _pageController = PageController();
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(1);
    });
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> pageColors = [
      const Color(0xffBA90C6),
      const Color(0xFF8EA7E9),
    ];

    int currentPageIndex = _currentPage.floor();
    int nextPageIndex = (currentPageIndex + 1) % pageColors.length;
    double pageProgress = _currentPage - currentPageIndex;

    final Color interpolatedBackgroundColor = Color.lerp(
      pageColors[currentPageIndex],
      pageColors[nextPageIndex],
      pageProgress,
    ) ??
        pageColors[currentPageIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [interpolatedBackgroundColor, const Color(0xFF19A7CE)],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: currentPageIndex == 1
              ? IconButton(
            onPressed: () {
              unawaited(
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                ),
              );
            },
            icon: const Icon(Icons.menu),
          )
              : null,
          backgroundColor: Colors.transparent,
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              widget.titles[currentPageIndex],
              key: ValueKey<int>(currentPageIndex),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          actions: currentPageIndex == 0
              ? [
            IconButton(
              onPressed: () {
                unawaited(
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
            ),
          ]
              : null,
        ),
        backgroundColor: Colors.transparent,
        body: GeneralContainer(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index.toDouble();
              });
            },
            children: [
              widget.secondaryView,
              widget.primaryView,
            ],
          ),
        ),
      ),
    );
  }
}
