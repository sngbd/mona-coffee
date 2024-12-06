// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/helper.dart';
import 'package:mona_coffee/core/utils/sizer.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/order_tracking_screen.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderScreen({super.key, required this.order});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedDeliveryMethod = 'Delivery';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<dynamic> cartItems = [];

  final Map<String, String> _deliveryIcons = {
    'Delivery': 'assets/icons/delivery_icon.svg',
    'Take-away': 'assets/icons/take_away_icon.svg',
    'Dine-in': 'assets/icons/dine_in_icon.svg',
  };

  String deliveryAddress = 'No saved address';
  TimeOfDay? selectedTime;
  String? seat;
  int? fee;
  double? distance;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _selectedDeliveryMethod = widget.order['orderType'] ?? 'Delivery';
    deliveryAddress = widget.order['address'] ?? '';
    _notesController.text = widget.order['notes'] ?? '';
    cartItems = widget.order['items'];
    selectedTime = widget.order['timeToCome'] != null
        ? TimeOfDay.fromDateTime(widget.order['timeToCome'].toDate())
        : null;
    if (widget.order['orderType'] == 'Dine-in') {
      seat = widget.order['seatNumber'] ?? 'Pending';
    }
    fee = widget.order['deliveryFee'];
    distance = widget.order['distance'];
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _getSubtotal() {
    return cartItems.fold(
        0, (total, item) => total + (item['price'] * item['quantity']));
  }

  double _getTotal() {
    return _getSubtotal() +
        (_selectedDeliveryMethod == 'Delivery' ? 15000 : 0) +
        2000;
  }

  // Format waktu untuk ditampilkan
  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time to visit';
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final format = DateFormat.jm();
    return format.format(selectedDateTime);
  }

  Future<LatLng> _getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    } else {
      throw Exception('Address not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);

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
            seat != null
                ? Column(children: [
                    _buildSeatDetails(),
                    const SizedBox(height: 12),
                  ])
                : const SizedBox.shrink(),
            _notesController.text != ""
                ? Column(
                    children: [
                      _buildNotesSection(),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink(),
            _buildOrderDetails(),
            const SizedBox(height: 20),
            _buildStatus(),
            const SizedBox(height: 20),
            // _buildMapDriver(),
            // const SizedBox(height: 20),
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
        'Order',
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
                  child: Column(
                    children: [
                      Text(
                        deliveryAddress,
                        style: const TextStyle(color: mDarkBrown),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(mBrown),
                        ),
                        onPressed: () async {
                          try {
                            LatLng destinationLocation =
                                await _getCoordinatesFromAddress(
                                    deliveryAddress);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderTrackingScreen(
                                  destinationLocation: destinationLocation,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Failed to get coordinates: $e')),
                            );
                          }
                        },
                        child: const Text('Track Order',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Text(
                    _formatTime(selectedTime),
                    style: const TextStyle(color: mDarkBrown),
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
          const SizedBox(
            height: 6,
          ),
          SizedBox(
            height: 60,
            child: TextField(
              controller: _notesController,
              readOnly: true,
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

  Widget _buildSeatDetails() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.table_bar, color: mBrown),
              SizedBox(width: 8),
              Text("Seat:",
                  style: TextStyle(
                    color: mDarkBrown,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: seat == "Pending"
                    ? Text(
                        "Pending",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        seat!,
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
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
          _buildPriceRow('Subtotal', Helper().formatCurrency(_getSubtotal())),
          _selectedDeliveryMethod == 'Delivery'
              ? (fee != null && distance != null)
                  ? _buildPriceRow('Delivery Fee',
                      '${Helper().formatCurrency(fee!)} (${distance != double.infinity ? distance!.toStringAsFixed(0) : '∞'} km)')
                  : _buildPriceRow(
                      'Delivery Fee', Helper().formatCurrency(15000))
              : const SizedBox.shrink(),
          _buildPriceRow('Other Fee', 'Rp 2.000'),
          const Divider(),
          _buildPriceRow('Total', Helper().formatCurrency(_getTotal()),
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.coffee, color: mBrown),
              SizedBox(width: 8),
              Text("Status:",
                  style: TextStyle(
                    color: mDarkBrown,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  Helper().toTitleCase(widget.order['status']),
                  style: TextStyle(
                    color: widget.order['status'] == 'pending'
                        ? Colors.grey[600]
                        : widget.order['status'] == 'processing'
                            ? mDarkBrown
                            : widget.order['status'] == 'cancelled'
                                ? Colors.red
                                : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildMapDriver() {
  //   return _buildSectionContainer(
  //     child: const Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Expanded(child: OrderTrackingScreen()),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildOrderItem(Map<String, dynamic> cartItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              cartItem['imageUrl'],
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
                  '${cartItem['quantity']}x ${Helper().toTitleCase(cartItem['name'])}',
                  style: const TextStyle(
                      color: mBrown, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      '${cartItem['size']} - ${cartItem['type']}',
                      style: const TextStyle(color: mDarkBrown),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            Helper().formatCurrency(cartItem['price'] * cartItem['quantity']),
            style: const TextStyle(color: mDarkBrown),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    Widget platformButton = const SizedBox.shrink();
    if (widget.order['paymentMethod'] == 'E-Banking') {
      if (widget.order['bankName'] == 'BCA') {
        platformButton =
            _buildPlatformButton('BCA', 'assets/images/bca_logo.png');
      } else if (widget.order['bankName'] == 'BNI') {
        platformButton =
            _buildPlatformButton('BNI', 'assets/images/bni_logo.png');
      } else if (widget.order['bankName'] == 'BRI') {
        platformButton =
            _buildPlatformButton('BRI', 'assets/images/bri_logo.png');
      } else if (widget.order['bankName'] == 'Mandiri') {
        platformButton =
            _buildPlatformButton('Mandiri', 'assets/images/mandiri_logo.png');
      }
    } else if (widget.order['paymentMethod'] == 'E-Wallet') {
      if (widget.order['ewalletName'] == 'GoPay') {
        platformButton =
            _buildPlatformButton('GoPay', 'assets/images/gopay_logo.png');
      } else if (widget.order['ewalletName'] == 'DANA') {
        platformButton =
            _buildPlatformButton('DANA', 'assets/images/dana_logo.png');
      } else if (widget.order['ewalletName'] == 'OVO') {
        platformButton =
            _buildPlatformButton('OVO', 'assets/images/ovo_logo.png');
      } else if (widget.order['ewalletName'] == 'ShopeePay') {
        platformButton = _buildPlatformButton(
            'ShopeePay', 'assets/images/shopeepay_logo.png');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Paid with',
            style: TextStyle(
                color: mDarkBrown, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPaymentButton(widget.order['paymentMethod']),
            const SizedBox(width: 12),
            platformButton,
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformButton(String bankName, String logoPath) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: Sizer.screenWidth * 0.4,
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

  Widget _buildPaymentButton(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
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
}
