import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mona_coffee/core/utils/common.dart';

class ActivityIndicator extends StatelessWidget {
  const ActivityIndicator({super.key});

  final SpinKitCubeGrid spinkit = const SpinKitCubeGrid(
    color: mDarkBrown,
    size: 80.0,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [spinkit],
      ),
    );
  }
}
