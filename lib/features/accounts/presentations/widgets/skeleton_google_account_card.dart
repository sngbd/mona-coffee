import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/shimmer_block.dart';
import 'package:mona_coffee/core/utils/sizer.dart';

class SkeletonGoogleAccountCard extends StatelessWidget {
  const SkeletonGoogleAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 60),
          Center(
            child: ShimmerBlock(
              height: 200,
              width: 200,
              radius: 100,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: mDarkBrown,
            ),
          ),
          SizedBox(height: 10),
          ShimmerBlock(
            height: 35,
            width: 500,
            radius: 5,
          ),
          SizedBox(height: 20),
          Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: mDarkBrown,
            ),
          ),
          SizedBox(height: 10),
          ShimmerBlock(
            height: 35,
            width: 500,
            radius: 5,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
