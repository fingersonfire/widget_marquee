library widget_marquee;

import 'dart:developer';
import 'package:flutter/material.dart';

/// Rotates the [child] widget indefinitely along the horizontal axis if the
/// content extends pass the edge of the render area.
class Marquee extends StatefulWidget {
  const Marquee({
    Key? key,
    required this.child,
    this.animate = true,
    this.delayDuration = const Duration(milliseconds: 1500),
    this.gap = 50,
    this.loopDuration = const Duration(milliseconds: 8000),
    this.loopPause = 5000,
    this.onScrollingTap,
    this.onTap,
    this.pixelsPerSecond = 0,
    this.uniqueId = '',
  }) : super(key: key);

  final Widget child;
  final bool animate;

  /// [delayDuration] - One time delay to wait before starting the text rotation
  final Duration delayDuration;

  /// [gap] - Spacing to add between widget end and start
  final double gap;

  /// [loopDuration] - Time for one full rotation of the child
  final Duration loopDuration;

  /// [loopPause] - Time to wait after each rotation before next
  final int loopPause;
  final Future<void> Function()? onScrollingTap;
  final Future<void> Function()? onTap;

  /// [pixelsPerSecond] - Alternate to loop duration
  final int pixelsPerSecond;
  final String uniqueId;

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with TickerProviderStateMixin {
  late double contentArea;

  double initMax = 0;
  bool isScrolling = false;
  ScrollController? scrollController;
  List<Widget> widgets = <Widget>[];
  String uniqueId = '';

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (widgets.isEmpty ||
        widget.child.toString() != widgets[0].toString() ||
        widget.uniqueId != uniqueId) {
      uniqueId = widget.uniqueId;
      isScrolling = false;
      widgets = <Widget>[widget.child];

      scrollController?.jumpTo(0);
      scrollController?.dispose();

      scrollController = ScrollController(
        initialScrollOffset: 0.0,
        keepScrollOffset: false,
      );

      if (widget.animate) {
        WidgetsBinding.instance?.addPostFrameCallback(scroll);
      }
    } else {
      if (widget.animate && !isScrolling) {
        WidgetsBinding.instance?.addPostFrameCallback(scroll);
      } else if (!widget.animate && isScrolling) {
        isScrolling = false;
        scrollController?.jumpTo(0);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void scroll(_) async {
    if ((scrollController?.position.maxScrollExtent ?? 0) > 0) {
      Duration duration;

      // Add a sized box and duplicate widget to the row
      if (widgets.length == 1) {
        initMax = scrollController!.position.maxScrollExtent;

        widgets.add(SizedBox(width: widget.gap));
        widgets.add(widget.child);
      }

      await Future<dynamic>.delayed(widget.delayDuration);

      try {
        setState(() {
          isScrolling = true;
        });

        while (scrollController!.hasClients && isScrolling) {
          // Calculate the position where the duplicate widget lines up with the original
          final double scrollExtent =
              (initMax * 2) - (initMax - contentArea) + widget.gap;

          // Set the duration of the animation
          if (widget.pixelsPerSecond <= 0) {
            duration = widget.loopDuration;
          } else {
            duration = Duration(
              // Calculate the duration based on the pixels per second
              milliseconds:
                  ((scrollExtent / widget.pixelsPerSecond) * 1000).toInt(),
            );
          }

          await scrollController!.animateTo(
            scrollExtent,
            duration: duration,
            curve: Curves.linear,
          );

          // Jump to the beginning of the view to imitate loop
          scrollController!.jumpTo(0);

          int finishTime =
              DateTime.now().millisecondsSinceEpoch + widget.loopPause;

          while (DateTime.now().millisecondsSinceEpoch < finishTime &&
              isScrolling) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
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
    scrollController?.dispose();
    super.dispose();
  }
}
