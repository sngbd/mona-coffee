import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/accounts/presentations/payments/transaction_number_dialog.dart';

class BankSelectionDialog extends StatelessWidget {
  final Function(String) onBankSelected;
  final VoidCallback onCancel;
  final double amount;

  const BankSelectionDialog({
    super.key,
    required this.onBankSelected,
    required this.onCancel,
    required this.amount,
  });

  // Map bank names to their account numbers
  final Map<String, String> bankAccounts = const {
    'BCA': '1293111111111',
    'BNI': '1293222222222',
    'BRI': '1293333333333',
    'Mandiri': '1293444444444',
  };

  void _showTransactionNumber(BuildContext context, String bankName) {
    Navigator.of(context).pop(); // Close bank selection dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => TransactionNumberDialog(
        bankName: bankName,
        accountNumber: bankAccounts[bankName] ?? '',
        amount: amount,
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

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
                'Please select your bank',
                style: TextStyle(
                  color: mDarkBrown,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2,
                children: [
                  _buildBankButton(
                      'BCA', 'assets/images/bca_logo.png', context),
                  _buildBankButton(
                      'BNI', 'assets/images/bni_logo.png', context),
                  _buildBankButton(
                      'BRI', 'assets/images/bri_logo.png', context),
                  _buildBankButton(
                      'Mandiri', 'assets/images/mandiri_logo.png', context),
                ],
              ),
              const SizedBox(height: 40),
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

  Widget _buildBankButton(
      String bankName, String logoPath, BuildContext context) {
    return InkWell(
      onTap: () {
        onBankSelected(bankName);
        _showTransactionNumber(context, bankName);
      },
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: mBrown),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          logoPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
