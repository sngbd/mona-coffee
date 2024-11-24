import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class QRISSelectionDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final double amount;

  const QRISSelectionDialog({
    super.key,
    required this.onCancel,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan here to pay',
                style: TextStyle(
                  color: mDarkBrown,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: mBrown, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Replace with actual QRIS code widget or image
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Icon(
                        Icons.qr_code_2,
                        size: 150,
                        color: mBrown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rp ${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: mDarkBrown,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Powered by ',
                    style: TextStyle(
                      color: mDarkBrown,
                      fontSize: 12,
                    ),
                  ),
                  Image.asset(
                    'assets/images/qris_logo.png',
                    width: 48,
                    height: 14,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
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
