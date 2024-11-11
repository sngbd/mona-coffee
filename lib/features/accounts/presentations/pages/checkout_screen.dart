import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/accounts/presentations/payments/bank_selection_dialog.dart';
import 'package:mona_coffee/features/accounts/presentations/payments/qris_selection_dialog.dart';
import 'package:mona_coffee/features/accounts/presentations/widgets/delivery_method_selector.dart';
import 'package:mona_coffee/features/accounts/presentations/payments/ewallet_selection_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedTemperature;
  String _selectedDeliveryMethod = 'Delivery';

  final Map<String, String> _deliveryIcons = {
    'Delivery': 'assets/icons/delivery_icon.svg',
    'Take-away': 'assets/icons/take_away_icon.svg',
    'Dine-in': 'assets/icons/dine_in_icon.svg',
  };

  String deliveryAddress = 'No saved address';

  bool isEditing = false;

  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightPink,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliverySection(),
            const SizedBox(height: 12),
            _buildDeliveryAddress(),
            const SizedBox(height: 12),
            _buildNotesSection(),
            const SizedBox(height: 12),
            _buildOrderDetails(),
            const SizedBox(height: 20),
            _buildPaymentMethods(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: mDarkBrown),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Checkout',
        style: TextStyle(
          color: mDarkBrown,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDeliverySection() {
    return _buildSectionContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                _deliveryIcons[_selectedDeliveryMethod] ??
                    _deliveryIcons['Delivery']!,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedDeliveryMethod,
                style:
                    const TextStyle(color: mBrown, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          _buildChangeButton(() {}),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: mBrown),
              SizedBox(width: 8),
              Text('Deliver to:',
                  style: TextStyle(
                      color: mDarkBrown, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: _addressController,
                        style: const TextStyle(color: mDarkBrown),
                        decoration: const InputDecoration(
                          hintText: 'Enter your address',
                          hintStyle: TextStyle(color: mDarkBrown),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              deliveryAddress = value;
                            }
                            isEditing = false;
                          });
                        },
                      )
                    : Text(
                        deliveryAddress,
                        style: const TextStyle(color: mDarkBrown),
                      ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (isEditing) {
                      // Save the changes
                      if (_addressController.text.isNotEmpty) {
                        deliveryAddress = _addressController.text;
                      }
                      isEditing = false;
                    } else {
                      // Start editing
                      _addressController.text = deliveryAddress;
                      isEditing = true;
                    }
                  });
                },
                child: Text(
                  isEditing ? 'Save' : 'Edit',
                  style: const TextStyle(
                      color: mBrown, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(color: mDarkBrown, fontWeight: FontWeight.w600),
          ),
          const Text(
            'Optional',
            style: TextStyle(color: mDarkBrown, fontSize: 12),
          ),
          const SizedBox(
            height: 6,
          ),
          SizedBox(
            height: 60,
            child: TextField(
              maxLength: 200,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Example: add more plz',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.text_snippet, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your order:',
            style: TextStyle(
              color: mDarkBrown,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildOrderItem(),
          const Divider(),
          // Price Details
          _buildPriceRow('Subtotal', 'Rp 50.000'),
          _buildPriceRow('Delivery Fee', 'Rp 15.000'),
          _buildPriceRow('Discount', 'Rp 0'),
          _buildPriceRow('Other Fee', 'Rp 2.000'),
          const Divider(),
          _buildPriceRow('Total', 'Rp 67.000', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildOrderItem() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'assets/images/coffee.png',
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1x Mocha Latte',
                style: TextStyle(color: mBrown, fontWeight: FontWeight.bold),
              ),
              // Wrap Row in Padding instead of Container with negative margin
              Padding(
                padding: const EdgeInsets.only(
                    right: 10), // Add padding to other elements
                child: Row(
                  children: [
                    Transform.translate(
                      offset: const Offset(
                          -10, 0), // Move radio group left by 10 pixels
                      child: Row(
                        children: [
                          // Hot Option
                          Radio<String>(
                            value: 'Hot',
                            groupValue: _selectedTemperature,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedTemperature = value;
                              });
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const Text('Hot',
                              style: TextStyle(color: mDarkBrown)),
                          const SizedBox(width: 16),
                          // Iced Option
                          Radio<String>(
                            value: 'Iced',
                            groupValue: _selectedTemperature,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedTemperature = value;
                              });
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const Text('Iced',
                              style: TextStyle(color: mDarkBrown)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Text('Medium', style: TextStyle(color: mDarkBrown)),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            context.goNamed('update_order');
          },
          child: const Text('Edit',
              style: TextStyle(color: mBrown, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Pay with',
            style: TextStyle(
                color: mDarkBrown, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPaymentButton('E-banking'),
            const SizedBox(width: 8),
            _buildPaymentButton('QRIS'),
            const SizedBox(width: 8),
            _buildPaymentButton('E-wallet'),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentButton(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (label == 'E-banking') {
            showDialog(
              context: context,
              builder: (context) => BankSelectionDialog(
                amount: 67000,
                onBankSelected: (bank) {
                  // Handle bank selection here
                  // You can add more logic here, like navigating to the next screen
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          } else if (label == 'E-wallet') {
            showDialog(
              context: context,
              builder: (context) => EWalletSelectionDialog(
                amount: 67000,
                onEWalletSelected: (wallet) {
                  // Handle e-wallet selection here
                  // Tambahkan logika pemrosesan e-wallet di sini
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          } else if (label == 'QRIS') {
            // Get the total amount from your order details
            double totalAmount = 67000;

            showDialog(
              context: context,
              builder: (context) => QRISSelectionDialog(
                amount: totalAmount,
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          }
          // Handle other payment methods here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: mBrown,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: mBrown),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: mDarkBrown,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: mDarkBrown,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DeliveryMethodSelector(
            currentMethod: _selectedDeliveryMethod,
            onMethodSelected: (method) {
              setState(() {
                _selectedDeliveryMethod = method;
              });
              if (kDebugMode) {
                print('Selected method: $method');
              }
            },
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: mBrown,
      ),
      child: const Text(
        'Change',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
