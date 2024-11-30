import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/checkout_bloc.dart';
import 'package:mona_coffee/features/accounts/presentations/payments/transaction_number_dialog.dart'; // Add this import

class BankSelectionDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final double amount;
  final String userName;
  final String address;
  final String timeToCome;
  final String notes;
  final String orderType;
  final List<CartItem> cartItems;

  const BankSelectionDialog({
    super.key,
    required this.onCancel,
    required this.amount,
    required this.userName,
    required this.address,
    required this.timeToCome,
    required this.notes,
    required this.orderType,
    required this.cartItems,
  });

  // Map bank names to their account numbers
  final Map<String, String> bankAccounts = const {
    'BCA': '1293111111111',
    'BNI': '1293222222222',
    'BRI': '1293333333333',
    'Mandiri': '1293444444444',
  };

  void _showTransactionNumber(BuildContext context, String bankName) {
    final checkoutBloc = context.read<CheckoutBloc>();

    // Dispatch SelectPaymentMethod event
    checkoutBloc.add(SelectPaymentMethod(
      method: 'E-Banking',
      bankName: bankName,
      accountNumber: bankAccounts[bankName],
    ));

    Navigator.of(context).pop(); // Close bank selection dialog
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return TransactionNumberDialog(
            bankName: bankName,
            accountNumber: bankAccounts[bankName] ?? '',
            amount: amount,
            onCancel: () {
              Navigator.of(context).pop();
            },
            userName: userName,
            address: address,
            timeToCome: timeToCome,
            notes: notes,
            orderType: orderType,
            cartItems: cartItems,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BackdropFilter(
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
      ),
    );
  }

  Widget _buildBankButton(
      String bankName, String logoPath, BuildContext context) {
    return InkWell(
      onTap: () {
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
