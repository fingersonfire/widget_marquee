import 'package:flutter/material.dart';
import 'package:widget_marquee/widget_marquee.dart';

void main() {
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const Marquee(
              delay: Duration(milliseconds: 3000),
              duration: Duration(milliseconds: 8000),
              child: Text(
                'Very long text that bleeds out of the rendering space',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
