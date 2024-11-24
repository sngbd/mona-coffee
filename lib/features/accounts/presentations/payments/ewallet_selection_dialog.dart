import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/accounts/presentations/payments/transaction_number_dialog.dart';

class EWalletSelectionDialog extends StatelessWidget {
  final Function(String) onEWalletSelected;
  final VoidCallback onCancel;
  final double amount;

  const EWalletSelectionDialog({
    super.key,
    required this.onEWalletSelected,
    required this.onCancel,
    required this.amount,
  });

  // Map e-wallet names to their numbers
  final Map<String, String> ewalletAccounts = const {
    'GoPay': '081234567890',
    'DANA': '081234567891',
    'OVO': '081234567892',
    'ShopeePay': '081234567893',
  };

  void _showTransactionNumber(BuildContext context, String walletName) {
    Navigator.of(context).pop(); // Close e-wallet selection dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => TransactionNumberDialog(
        bankName: walletName,
        accountNumber: ewalletAccounts[walletName] ?? '',
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
                'Please select your e-wallet',
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
                  _buildEWalletButton(
                      'GoPay', 'assets/images/gopay_logo.png', context),
                  _buildEWalletButton(
                      'DANA', 'assets/images/dana_logo.png', context),
                  _buildEWalletButton(
                      'OVO', 'assets/images/ovo_logo.png', context),
                  _buildEWalletButton(
                      'ShopeePay', 'assets/images/shopeepay_logo.png', context),
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

  Widget _buildEWalletButton(
      String walletName, String logoPath, BuildContext context) {
    return InkWell(
      onTap: () {
        onEWalletSelected(walletName);
        _showTransactionNumber(context, walletName);
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
