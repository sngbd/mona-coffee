import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/widgets/flasher.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/cart_bloc.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/checkout_bloc.dart';
import 'package:mona_coffee/features/home/presentation/pages/home_screen.dart';

class TransactionNumberDialog extends StatefulWidget {
  final String bankName;
  final String walletName;
  final String accountNumber;
  final double amount;
  final VoidCallback onCancel;
  final String userName;
  final String address;
  final Timestamp? timeToCome;
  final String notes;
  final String orderType;
  final List<CartItem> cartItems;
  final int? deliveryFee;
  final double? distance;

  const TransactionNumberDialog({
    super.key,
    this.bankName = '',
    this.walletName = '',
    required this.accountNumber,
    required this.amount,
    required this.onCancel,
    required this.userName,
    required this.address,
    required this.timeToCome,
    required this.notes,
    required this.orderType,
    required this.cartItems,
    required this.deliveryFee,
    required this.distance,
  });

  @override
  State<TransactionNumberDialog> createState() =>
      _TransactionNumberDialogState();
}

class _TransactionNumberDialogState extends State<TransactionNumberDialog> {
  File? _transferProof;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _transferProof = File(image.path);
      });
    }
  }

  Future<void> _confirmTransaction() async {
    if (_transferProof == null) {
      Flasher.showSnackBar(
        context,
        'Error',
        'Please upload transfer proof first',
        Icons.error_outline,
        Colors.red,
      );
      return;
    }

    final checkoutBloc = context.read<CheckoutBloc>();

    // Dispatch SelectPaymentMethod event first
    checkoutBloc.add(SelectPaymentMethod(
      method: widget.bankName.isNotEmpty ? 'E-Banking' : 'E-Wallet',
      bankName: widget.bankName.isNotEmpty ? widget.bankName : null,
      walletName: widget.bankName.isNotEmpty ? null : widget.walletName,
      accountNumber: widget.accountNumber,
    ));

    // Then dispatch ConfirmTransaction event
    checkoutBloc.add(ConfirmTransaction(
      userName: widget.userName,
      address: widget.address,
      timeToCome: widget.timeToCome,
      notes: widget.notes,
      orderType: widget.orderType,
      cartItems: widget.cartItems,
      amount: widget.amount,
      transferProofPath: _transferProof!.path,
      bankName: widget.bankName,
      walletName: widget.walletName,
      deliveryFee: widget.deliveryFee,
      distance: widget.distance,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutError) {
          Flasher.showSnackBar(
            context,
            'Error',
            state.message,
            Icons.error_outline,
            Colors.red,
          );
        } else if (state is CheckoutSuccess) {
          context.read<CartBloc>().add(ClearCart());
          Flasher.showSnackBar(
            context,
            'Success',
            'Transaction confirmed successfully',
            Icons.check_circle_outline,
            Colors.green,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(page: 2, isOngoing: false),
            ),
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
                    Clipboard.setData(
                        ClipboardData(text: widget.accountNumber));
                    Flasher.showSnackBar(
                      context,
                      'Success',
                      'Account number copied to clipboard',
                      Icons.check_circle_outline,
                      Colors.green,
                    );
                  },
                  child: Text(
                    widget.accountNumber,
                    style: const TextStyle(
                      color: mDarkBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rp ${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: mDarkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Upload proof button
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: Text(
                    _transferProof == null
                        ? 'Upload Transfer Proof'
                        : 'Change Transfer Proof',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm button
                BlocBuilder<CheckoutBloc, CheckoutState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is CheckoutLoading
                            ? null
                            : _confirmTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: state is CheckoutLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Confirm Transaction',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onCancel,
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
}
