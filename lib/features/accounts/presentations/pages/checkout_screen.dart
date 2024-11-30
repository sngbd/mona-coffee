import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
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
  String _selectedDeliveryMethod = 'Delivery';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool isLoading = true;
  List<CartItem> cartItems = [];

  final Map<String, String> _deliveryIcons = {
    'Delivery': 'assets/icons/delivery_icon.svg',
    'Take-away': 'assets/icons/take_away_icon.svg',
    'Dine-in': 'assets/icons/dine_in_icon.svg',
  };

  String deliveryAddress = 'No saved address';
  TimeOfDay? selectedTime;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cartSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

        final items = cartSnapshot.docs.map((doc) {
          final data = doc.data();
          return CartItem(
            compositeKey: data['compositeKey'] ?? '',
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            size: data['size'] ?? '',
            price: double.parse((data['price'] ?? 0).toStringAsFixed(0)),
            quantity: data['quantity'] ?? 1,
            imageUrl: data['imageUrl'] ?? '',
            timestamp: data['timestamp'] ?? Timestamp.now(),
          );
        }).toList();

        setState(() {
          cartItems = items;
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching cart items: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _getSubtotal() {
    return cartItems.fold(
        0, (total, item) => total + (item.price * item.quantity));
  }

  double _getTotal() {
    return _getSubtotal() + 15000 + 2000;
  }

  // Fungsi untuk menampilkan time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: mDarkBrown,
              dayPeriodTextColor: mDarkBrown,
              dialHandColor: mBrown,
              dialBackgroundColor: mLightPink,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: mBrown,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Format waktu untuk ditampilkan
  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time to visit';
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightPink,
      appBar: _buildAppBar(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: mBrown))
          : SingleChildScrollView(
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
    final bool isDelivery = _selectedDeliveryMethod == 'Delivery';
    final String title = isDelivery ? 'Deliver to:' : 'Time to come to resto:';

    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isDelivery ? Icons.location_on : Icons.access_time_filled,
                  color: mBrown),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: mDarkBrown, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isDelivery)
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
                )
              else
                Expanded(
                  child: Text(
                    _formatTime(selectedTime),
                    style: const TextStyle(color: mDarkBrown),
                  ),
                ),
              TextButton(
                onPressed: () {
                  if (isDelivery) {
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
                  } else {
                    _selectTime(context);
                  }
                },
                child: Text(
                  isDelivery ? (isEditing ? 'Save' : 'Edit') : 'Edit',
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
              controller: _notesController, // Tambahkan controller
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
          if (cartItems.isEmpty)
            const Center(child: Text('No items in cart'))
          else
            ...cartItems.map((item) => _buildOrderItem(item)),
          const Divider(),
          _buildPriceRow('Subtotal', 'Rp ${_getSubtotal().toStringAsFixed(0)}'),
          _buildPriceRow('Delivery Fee', 'Rp 15.000'),
          _buildPriceRow('Other Fee', 'Rp 2.000'),
          const Divider(),
          _buildPriceRow('Total', 'Rp ${_getTotal().toStringAsFixed(0)}',
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem cartItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              cartItem.imageUrl,
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
                Text(
                  '${cartItem.quantity}x ${cartItem.name}',
                  style: const TextStyle(
                      color: mBrown, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      '${cartItem.size} - ${cartItem.type}',
                      style: const TextStyle(color: mDarkBrown),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'Rp ${cartItem.price * cartItem.quantity}',
            style: const TextStyle(color: mDarkBrown),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final total = _getTotal();
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
            _buildPaymentButton('E-banking', total),
            const SizedBox(width: 8),
            _buildPaymentButton('QRIS', total),
            const SizedBox(width: 8),
            _buildPaymentButton('E-wallet', total),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentButton(String label, double amount) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          switch (label) {
            case 'E-banking':
              showDialog(
                context: context,
                builder: (context) => BankSelectionDialog(
                  amount: amount,
                  onCancel: () => Navigator.of(context).pop(),
                  userName: 'Lorenzo',
                  address: _addressController.text,
                  timeToCome: selectedTime.toString(),
                  notes: _notesController.text,
                  orderType: _selectedDeliveryMethod,
                  cartItems: cartItems,
                ),
              );
              break;
            case 'E-wallet':
              showDialog(
                context: context,
                builder: (context) => EWalletSelectionDialog(
                  amount: amount,
                  onCancel: () => Navigator.of(context).pop(),
                  userName: 'Lorenzo',
                  address: _addressController.text,
                  timeToCome: selectedTime.toString(),
                  notes: _notesController.text,
                  orderType: _selectedDeliveryMethod,
                  cartItems: cartItems,
                ),
              );
              break;
            case 'QRIS':
              showDialog(
                context: context,
                builder: (context) => QRISSelectionDialog(
                  amount: amount,
                  onCancel: () => Navigator.of(context).pop(),
                  userName: 'Lorenzo',
                  address: _addressController.text,
                  timeToCome: selectedTime.toString(),
                  notes: _notesController.text,
                  orderType: _selectedDeliveryMethod,
                  cartItems: cartItems,
                ),
              );
              break;
          }
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
