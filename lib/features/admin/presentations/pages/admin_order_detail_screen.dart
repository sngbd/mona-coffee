import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const AdminOrderDetailScreen({
    super.key,
    required this.orderData,
  });

  String formatPrice(num price) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final items = (orderData['items'] as List).cast<Map<String, dynamic>>();
    final subtotal = items.fold<num>(
      0,
      (total, item) => total + (item['price'] as num) * (item['quantity'] as num),
    );
    final deliveryFee =
        orderData['orderType'].toString().toLowerCase() == 'delivery'
            ? 15000
            : 0;
    const otherFee = 2000;
    final total = subtotal + deliveryFee + otherFee;

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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            // Customer Info Card
            Card(
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
                          orderData['userName'] ?? 'Unknown',
                          style: const TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Order method: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: mDarkBrown,
                              ),
                            ),
                            Text(
                              orderData['orderType'] ?? 'Unknown',
                              style: const TextStyle(color: mDarkBrown),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            (orderData['createdAt'] as Timestamp).toDate(),
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
                        (orderData['notes']?.isNotEmpty ?? false)
                            ? orderData['notes']!
                            : 'Tidak ada notes',
                        style: const TextStyle(color: mDarkBrown),
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
                side: const BorderSide(color: mDarkBrown),
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
                    if (deliveryFee > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Fee',
                            style: TextStyle(color: mDarkBrown),
                          ),
                          Text(
                            formatPrice(deliveryFee),
                            style: const TextStyle(color: mDarkBrown),
                          ),
                        ],
                      ),
                    ],
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
                    // Payment Method
                    Center(
                      child: Text(
                        () {
                          final paymentMethod =
                              orderData['paymentMethod'] ?? 'Unknown';
                          if (paymentMethod.toLowerCase() == 'e-banking') {
                            return 'Pay with ${orderData['bankName'] ?? 'Bank'}';
                          } else if (paymentMethod.toLowerCase() ==
                              'e-wallet') {
                            return 'Pay with ${orderData['ewalletName'] ?? 'E-Wallet'}';
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
}
