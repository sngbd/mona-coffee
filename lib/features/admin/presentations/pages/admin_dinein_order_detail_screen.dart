import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDineInOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const AdminDineInOrderDetailScreen({
    super.key,
    required this.orderData,
  });

  @override
  State<AdminDineInOrderDetailScreen> createState() =>
      _AdminDineInOrderDetailScreenState();
}

class _AdminDineInOrderDetailScreenState
    extends State<AdminDineInOrderDetailScreen> {
  bool isEditing = false;
  late TextEditingController _seatController;
  late String seatNumber;

  String formatPrice(num price) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  @override
  void initState() {
    super.initState();
    seatNumber = widget.orderData['seatNumber'] ?? '1A';
    _seatController = TextEditingController(text: seatNumber);
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.orderData['items'] as List).cast<Map<String, dynamic>>();
    final subtotal = items.fold<num>(
      0,
      (total, item) => total + (item['price'] as num) * (item['quantity'] as num),
    );
    const otherFee = 2000;
    final total = subtotal + otherFee;

    return Scaffold(
      backgroundColor: mLightOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: mDarkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Order detail',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: mBrown),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Customer name: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                        Text(
                          widget.orderData['userName'] ?? 'Unknown',
                          style: const TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Order method: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: mDarkBrown,
                              ),
                            ),
                            Text(
                              'Dine-in',
                              style: TextStyle(color: mDarkBrown),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            (widget.orderData['createdAt'] as Timestamp).toDate(),
                          ),
                          style: const TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Notes Card
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: mDarkBrown),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: mDarkBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (widget.orderData['notes']?.isNotEmpty ?? false)
                            ? widget.orderData['notes']!
                            : 'Tidak ada notes',
                        style: const TextStyle(color: mDarkBrown),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Customer Seat Card
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: mBrown),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Input customer seat:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: mDarkBrown,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        child: isEditing
                            ? SizedBox(
                                width: 50,
                                child: TextField(
                                  controller: _seatController,
                                  style: const TextStyle(color: mDarkBrown),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 0,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      seatNumber = value;
                                      isEditing = false;
                                      // Here you can add logic to update the seat number in Firestore
                                    });
                                  },
                                ),
                              )
                            : Text(
                                seatNumber,
                                style: const TextStyle(color: mDarkBrown),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Order Summary Card
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: mBrown),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order summary:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: mDarkBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Order Items
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item['imageUrl'] != null
                                    ? Image.network(
                                        item['imageUrl'] as String,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child:
                                                const Icon(Icons.error_outline),
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/coffee.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['quantity']}x ${item['name']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: mDarkBrown,
                                    ),
                                  ),
                                  Text(
                                    item['type'] ?? '',
                                    style: const TextStyle(color: mDarkBrown),
                                  ),
                                  Text(
                                    item['size'] ?? '',
                                    style: const TextStyle(color: mDarkBrown),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                    const Divider(),
                    // Price Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(color: mDarkBrown),
                        ),
                        Text(
                          formatPrice(subtotal),
                          style: const TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Other Fee',
                          style: TextStyle(color: mDarkBrown),
                        ),
                        Text(
                          formatPrice(otherFee),
                          style: const TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Payment Method and Button
                    Center(
                      child: Text(
                        () {
                          final paymentMethod =
                              widget.orderData['paymentMethod'] ?? 'Unknown';
                          if (paymentMethod.toLowerCase() == 'e-banking') {
                            return 'Pay with ${widget.orderData['bankName'] ?? 'Bank'}';
                          } else if (paymentMethod.toLowerCase() ==
                              'e-wallet') {
                            return 'Pay with ${widget.orderData['ewalletName'] ?? 'E-Wallet'}';
                          } else {
                            return 'Pay with $paymentMethod';
                          }
                        }(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: mDarkBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _seatController.dispose();
    super.dispose();
  }
}