import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class DineInSeatReceiveScreen extends StatelessWidget {
  final String seatNumber;

  const DineInSeatReceiveScreen({
    super.key,
    required this.seatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightPink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Thank you text and seat number container
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Thank you for your order!\nHere\'s your seat number',
                    style: TextStyle(
                      color: mDarkBrown,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Seat Number Display
                  Text(
                    seatNumber,
                    style: const TextStyle(
                      color: mDarkBrown,
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Confirm Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to home or appropriate screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mBrown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
