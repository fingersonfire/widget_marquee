library widget_marquee;

import 'dart:developer';
import 'package:flutter/material.dart';

/// Rotates the [child] widget indefinitely along the horizontal axis if the
/// content extends pass the edge of the render area.
///
/// [delayDuration] - One time delay to wait before starting the text rotation
/// [gap] - Spacing to add between widget end and start
/// [loopDuration] - Time for one full rotation of the child
/// [onLoopFinish] - Function to run upon finishing each loop
/// [onScrollingTap]
/// [pixelsPerSecond] - Alternate to loop duration
class Marquee extends StatelessWidget {
  const Marquee({
    Key? key,
    required this.child,
    this.delayDuration = const Duration(milliseconds: 1500),
    this.gap = 50,
    this.loopDuration = const Duration(milliseconds: 8000),
    this.onLoopFinish = _onLoopFinish,
    this.onScrollingTap,
    this.onTap,
    this.pixelsPerSecond = 0,
    this.isStatic = false,
  }) : super(key: key);

  final Widget child;
  final Duration delayDuration;
  final double gap;
  final Duration loopDuration;
  final Future<void> Function() onLoopFinish;
  final Future<void> Function()? onScrollingTap;
  final Future<void> Function()? onTap;
  final int pixelsPerSecond;
  final bool isStatic;

  @override
  Widget build(BuildContext context) {
    return _Marquee(
      key: isStatic ? null : UniqueKey(),
      child: child,
      delay: delayDuration,
      gap: gap,
      loopDuration: loopDuration,
      onLoopFinish: onLoopFinish,
      onScrollingTap: onScrollingTap,
      onTap: onTap,
      pps: pixelsPerSecond,
    );
  }
}

class _Marquee extends StatefulWidget {
  const _Marquee({
    Key? key,
    required this.child,
    required this.delay,
    required this.gap,
    required this.loopDuration,
    required this.onLoopFinish,
    required this.onScrollingTap,
    required this.onTap,
    required this.pps,
  }) : super(key: key);

  final Widget child;
  final Duration delay;
  final double gap;
  final Duration loopDuration;
  final Future<void> Function() onLoopFinish;
  final Future<void> Function()? onScrollingTap;
  final Future<void> Function()? onTap;
  final int pps;

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee> with TickerProviderStateMixin {
  late double contentArea;
  bool isScrolling = false;
  late ScrollController scrollController;
  List<Widget> widgets = <Widget>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      widgets = <Widget>[widget.child];
    });

    // Initialize the scroll controller
    scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: false,
    );

    WidgetsBinding.instance?.addPostFrameCallback(scroll);
    super.didChangeDependencies();
  }

  void scroll(_) async {
    if (scrollController.position.maxScrollExtent > 0) {
      late Duration duration;
      final double initMax = scrollController.position.maxScrollExtent;

      // Add a sized box and duplicate widget to the row
      setState(() {
        widgets.add(SizedBox(width: widget.gap));
        widgets.add(widget.child);
      });

      await Future<dynamic>.delayed(widget.delay);

      try {
        setState(() {
          isScrolling = true;
        });

        while (scrollController.hasClients) {
          // Calculate the position where the duplicate widget lines up with the original
          final scrollExtent =
              (initMax * 2) - (initMax - contentArea) + widget.gap;

          // Set the duration of the animation
          if (widget.pps <= 0) {
            duration = widget.loopDuration;
          } else {
            duration = Duration(
              // Calculate the duration based on the pixels per second
              milliseconds: ((scrollExtent / widget.pps) * 1000).toInt(),
            );
          }

          await scrollController.animateTo(
            scrollExtent,
            duration: duration,
            curve: Curves.linear,
          );

          // Jump to the beginning of the view to imitate loop
          scrollController.jumpTo(0);
          await widget.onLoopFinish();
        }
      } catch (e) {
        log('Marquee element has been disposed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        contentArea = constraints.maxWidth;

        // Thanks to how widgets work, the gesture detector is only triggered
        // if there's nothing clickable in the child
        if (widget.onTap != null || widget.onScrollingTap != null) {
          return GestureDetector(
            onTap: () async {
              if (isScrolling) {
                await widget.onScrollingTap!();
              } else {
                await widget.onTap!();
              }
            },
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: widgets,
              ),
              scrollDirection: Axis.horizontal,
              controller: scrollController,
            ),
          );
        } else {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widgets,
            ),
            scrollDirection: Axis.horizontal,
            controller: scrollController,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

Future<void> _onLoopFinish() async {}
