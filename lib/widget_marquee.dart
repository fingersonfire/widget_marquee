library widget_marquee;

import 'package:flutter/material.dart';

class Marquee extends StatefulWidget {
  const Marquee({
    required this.child,
    Key? key,
    this.delay = const Duration(seconds: 10),
    this.disableAnimation = false,
    this.duration = const Duration(seconds: 10),
    this.gap = 25,
    this.id,
    this.pause = const Duration(seconds: 5),
  }) : super(key: key);

  /// Widget to display in marquee
  final Widget child;

  /// Duration to wait before starting animation
  final Duration delay;

  /// If animation should be stopped and position reset
  final bool disableAnimation;

  /// Duration of marquee animation
  final Duration duration;

  /// Sized between end of child and beginning of next child instance
  final double gap;

  /// Used to track widget instance and prevent rebuilding unnecessarily if parent rebuilds
  final String? id;

  /// Time to pause animation inbetween loops
  final Duration pause;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<Offset> offset;
  late final ScrollController scrollController;

  String id = '';
  bool shouldScroll = false;

  @override
  void initState() {
    id = widget.id ?? DateTime.now().toString();

    animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-.5, 0),
    ).animate(animationController);

    scrollController = ScrollController();

    animationController.addListener(animationListener);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      animationHandler();
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant Marquee oldWidget) {
    id = widget.id ?? DateTime.now().toString();

    if (!shouldScroll || oldWidget.id != id) {
      animationController.reset();
      setState(() => shouldScroll = false);
    }

    if (!widget.disableAnimation && oldWidget.id != id) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        animationHandler();
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  animationHandler() async {
    if (scrollController.position.maxScrollExtent > 0) {
      setState(() => shouldScroll = true);

      await Future.delayed(widget.delay);
      animationController.forward();
    }
  }

  animationListener() async {
    if (animationController.status == AnimationStatus.completed) {
      animationController.reset();
      await Future.delayed(widget.pause);
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SlideTransition(
        position: offset,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: shouldScroll ? widget.gap : 0,
              ),
              child: widget.child,
            ),
            if (shouldScroll)
              Padding(
                padding: EdgeInsets.only(
                  right: widget.gap,
                ),
                child: widget.child,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
