import 'dart:math';

import 'package:flutter/material.dart';

class RandomHeightContainer extends StatefulWidget {
  final Color color;
  final Widget? child;

  const RandomHeightContainer({required this.color, this.child, super.key});

  @override
  State<RandomHeightContainer> createState() => _RandomHeightContainerState();
}

class _RandomHeightContainerState extends State<RandomHeightContainer> {
  double _height = 300;

  _resetHeight() {
    setState(() {
      _height = 300.0 + Random.secure().nextInt(100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _resetHeight();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: widget.color,
        height: _height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("点击条目可以改变高度"),
            widget.child ?? Container(),
          ],
        ),
      ),
    );
  }
}
