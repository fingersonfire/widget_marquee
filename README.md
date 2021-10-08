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

A marquee widget that loops content seamlessly in a continous animation. The marquee will only animate if the content contained in the widget extends pass the vertical edge of the screen.

## Usage

```dart
Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Marquee(
        child: Text('Very long text that bleeds out of the rendering space'),
        loopDuration: const Duration(milliseconds: 5000),
    ),
),
```