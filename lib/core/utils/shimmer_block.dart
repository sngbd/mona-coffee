import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBlock extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const ShimmerBlock(
      {super.key,
      required this.height,
      required this.width,
      required this.radius});

  ShimmerDirection getRandomDirection() {
    final random = Random();
    return random.nextBool() ? ShimmerDirection.rtl : ShimmerDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 1000),
        direction: getRandomDirection(),
        baseColor: mGray200,
        highlightColor: mGray50,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            color: mGray100,
          ),
        ),
      ),
    );
  }
}
