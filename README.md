<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A marquee widget that loops content seamlessly in a continous animation. The marquee will only animate if the content contained in the widget extends pass the horizontal edge of the screen.

Note: Current limitation is that the elements being displayed are not interactable during the animation.

## Usage

```dart
Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Marquee(
        duration: const Duration(milliseconds: 5000),
        child: Text('Very long text that bleeds out of the rendering space'),
    ),
),
```

## Parameters

**delay**: Duration to wait before next loop.

**disableAnimation**: Toggle whether or not to loop widget.

**duration**: The time in order to complete a full loop.

**gap**: The size between the widget end and looped widgets start.

**id**: Used to track widget instance and prevent rebuilding unnecessarily if parent rebuilds.

**pause**: Time to pause animation inbetween loops.