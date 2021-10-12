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
/// [pixelsPerSecond] - Alternate to loop duration
class Marquee extends StatelessWidget {
  const Marquee({
    Key? key,
    required this.child,
    this.delayDuration = const Duration(milliseconds: 1500),
    this.gap = 50,
    this.loopDuration = const Duration(milliseconds: 8000),
    this.onLoopFinish = _onLoopFinish,
    this.pixelsPerSecond = 0,
  }) : super(key: key);

  final Widget child;
  final Duration delayDuration;
  final double gap;
  final Duration loopDuration;
  final Future<void> Function() onLoopFinish;
  final int pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    return _Marquee(
      key: UniqueKey(),
      child: child,
      delay: delayDuration,
      gap: gap,
      loopDuration: loopDuration,
      onLoopFinish: onLoopFinish,
      pps: pixelsPerSecond,
    );
  }
}

class _Marquee extends StatefulWidget {
  const _Marquee({
    required Key key,
    required this.child,
    required this.delay,
    required this.gap,
    required this.loopDuration,
    required this.onLoopFinish,
    required this.pps,
  }) : super(key: key);

  final Widget child;
  final Duration delay;
  final double gap;
  final Duration loopDuration;
  final Future<void> Function() onLoopFinish;
  final int pps;

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee> with TickerProviderStateMixin {
  late ScrollController scrollController;
  late double contentArea;
  List<Widget> widgets = <Widget>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    widgets = <Widget>[widget.child];

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

        return Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: widgets,
            ),
            scrollDirection: Axis.horizontal,
            controller: scrollController,
          ),
        );
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
