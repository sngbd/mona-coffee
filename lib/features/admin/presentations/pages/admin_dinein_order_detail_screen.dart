import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mona_coffee/features/admin/data/repositories/admin_orders_repository.dart';

class AdminDineInOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final AdminOrdersRepository ordersRepository;

  const AdminDineInOrderDetailScreen({
    super.key,
    required this.orderData,
    required this.ordersRepository,
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

  void _showImagePreview(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Semi-transparent black background
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              // Interactive viewer for zoom and pan
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: mDarkBrown),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: mDarkBrown),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransferProofCard(
      BuildContext context, String? transferProofBase64) {
    if (transferProofBase64 == null || transferProofBase64.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transfer Proof',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: mDarkBrown,
                  ),
                ),
                // Hint text for preview
                Text(
                  'Tap image to preview',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _showImagePreview(context, transferProofBase64),
                  child: Image.memory(
                    base64Decode(transferProofBase64),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: mDarkBrown),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load transfer proof',
                              style: TextStyle(color: mDarkBrown),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSeatCard() {
    return SizedBox(
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
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: mDarkBrown.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
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
                            onSubmitted: (value) async {
                              try {
                                await widget.ordersRepository.updateSeatNumber(
                                  widget.orderData['orderId'],
                                  widget.orderData['userId'],
                                  value,
                                );

                                setState(() {
                                  seatNumber = value;
                                  isEditing = false;
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Seat number updated successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to update seat number: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                          ),
                        )
                      : Text(
                          seatNumber.isEmpty ? 'Set seat' : seatNumber,
                          style: TextStyle(
                            color: mDarkBrown,
                            fontStyle: seatNumber.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    seatNumber = widget.orderData['seatNumber'] ?? '';
    _seatController = TextEditingController(text: seatNumber);
  }

  @override
  Widget build(BuildContext context) {
    final items =
        (widget.orderData['items'] as List).cast<Map<String, dynamic>>();
    final subtotal = items.fold<num>(
      0,
      (total, item) =>
          total + (item['price'] as num) * (item['quantity'] as num),
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
                            (widget.orderData['createdAt'] as Timestamp)
                                .toDate(),
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
            _buildCustomerSeatCard(),

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
            const SizedBox(height: 16),
            _buildTransferProofCard(context, widget.orderData['transferProof']),
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
