import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/widgets/flasher.dart';

class TransactionNumberDialog extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final double amount;
  final VoidCallback onCancel;

  const TransactionNumberDialog({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.amount,
    required this.onCancel,
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
                "Here's the\ntransaction number",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mDarkBrown,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: accountNumber));
                  Flasher.showSnackBar(
                    context,
                    'Success',
                    'Account number copied to clipboard',
                    Icons.check_circle_outline,
                    Colors.green,
                  );
                },
                child: Text(
                  accountNumber,
                  style: const TextStyle(
                    color: mDarkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
