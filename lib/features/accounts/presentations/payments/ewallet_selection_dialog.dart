import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/checkout_bloc.dart';
import 'package:mona_coffee/features/accounts/presentations/payments/transaction_number_dialog.dart';

class EWalletSelectionDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final double amount;
  final String userName;
  final String address;
  final Timestamp? timeToCome;
  final String notes;
  final String orderType;
  final List<CartItem> cartItems;
  final int? deliveryFee;
  final double? distance;

  const EWalletSelectionDialog({
    super.key,
    required this.onCancel,
    required this.amount,
    required this.userName,
    required this.address,
    required this.timeToCome,
    required this.notes,
    required this.orderType,
    required this.cartItems,
    required this.deliveryFee,
    required this.distance,
  });

  // Map e-wallet names to their numbers
  final Map<String, String> ewalletAccounts = const {
    'GoPay': '081262481507',
    'DANA': '081262481507',
    'OVO': '081262481507',
    'ShopeePay': '081262481507',
  };

  void _showTransactionNumber(BuildContext context, String walletName) {
    final checkoutBloc = context.read<CheckoutBloc>();

    // Dispatch SelectPaymentMethod event
    checkoutBloc.add(SelectPaymentMethod(
      method: 'E-Wallet',
      walletName: walletName,
      accountNumber: ewalletAccounts[walletName],
    ));

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return TransactionNumberDialog(
            walletName: walletName,
            accountNumber: ewalletAccounts[walletName] ?? '',
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
            deliveryFee: deliveryFee,
            distance: distance,
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
                    _buildEWalletButton('ShopeePay',
                        'assets/images/shopeepay_logo.png', context),
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

  Widget _buildEWalletButton(
      String walletName, String logoPath, BuildContext context) {
    return InkWell(
      onTap: () {
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
