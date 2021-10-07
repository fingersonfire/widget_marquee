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
class Marquee extends StatelessWidget {
  const Marquee({
    Key? key,
    required this.child,
    this.delayDuration = const Duration(milliseconds: 1500),
    this.gap = 50,
    this.loopDuration = const Duration(milliseconds: 8000),
    this.onLoopFinish = _onLoopFinish,
  }) : super(key: key);

  final Widget child;
  final Duration delayDuration;
  final double gap;
  final Duration loopDuration;
  final Future<void> Function() onLoopFinish;

  @override
  Widget build(BuildContext context) {
    return _Marquee(
      key: UniqueKey(),
      child: child,
      delayDuration: delayDuration,
      gap: gap,
      loopDuration: loopDuration,
      onLoopFinish: onLoopFinish,
    );
  }
}

class _Marquee extends StatefulWidget {
  const _Marquee({
    required Key key,
    required this.child,
    required this.delayDuration,
    required this.gap,
    required this.loopDuration,
    required this.onLoopFinish,
  }) : super(key: key);

  final Widget child;
  final Duration delayDuration;
  final double gap;
  final Duration loopDuration;
  final Future<void> Function() onLoopFinish;

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

    scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: false,
    );
    WidgetsBinding.instance?.addPostFrameCallback(scroll);

    super.didChangeDependencies();
  }

  void scroll(_) async {
    if (scrollController.position.maxScrollExtent > 0) {
      final double initMax = scrollController.position.maxScrollExtent;

      setState(() {
        widgets.add(SizedBox(width: widget.gap));
        widgets.add(widget.child);
      });

      await Future<dynamic>.delayed(widget.delayDuration);

      while (scrollController.hasClients) {
        final scrollExtent =
            (initMax * 2) - (initMax - contentArea) + widget.gap;
        try {
          await scrollController.animateTo(
            scrollExtent,
            duration: widget.loopDuration,
            curve: Curves.linear,
          );
          scrollController.jumpTo(0);
          await widget.onLoopFinish();
        } catch (e) {
          log('Marquee element has been updated');
        }
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
