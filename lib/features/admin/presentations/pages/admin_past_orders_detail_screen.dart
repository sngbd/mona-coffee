import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class AdminPastOrderDetailScreen extends StatelessWidget {
  const AdminPastOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: mDarkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order detail',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 100),
            // Customer Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: mBrown),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Customer name:', 'Lorenzo'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Order method:', 'Delivery'),
                      ],
                    ),
                    const Text(
                      '08/09/2024',
                      style: TextStyle(
                        color: mDarkBrown,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Order Summary Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: mBrown),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order summary:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: mDarkBrown),
                    ),
                    const SizedBox(height: 16),
                    // Order Item
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/coffee.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1x Mocha Latte',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: mDarkBrown),
                            ),
                            Text(
                              'Hot',
                              style: TextStyle(
                                color: mDarkBrown,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Medium',
                              style: TextStyle(
                                color: mDarkBrown,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Price Summary
                    _buildPriceRow('Subtotal', 'Rp 50.000'),
                    const SizedBox(height: 8),
                    _buildPriceRow('Delivery Fee', 'Rp 15.000'),
                    const SizedBox(height: 8),
                    _buildPriceRow('Discount', 'Rp 0'),
                    const SizedBox(height: 8),
                    _buildPriceRow('Other Fee', 'Rp 2.000'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildPriceRow('Total', 'Rp 67.000', isTotal: true),
                    const SizedBox(height: 8),
                    // Payment Method
                    const Divider(),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Pay with Gopay',
                        style: TextStyle(
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
              color: mDarkBrown, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: mDarkBrown),
        ),
        Text(
          amount,
          style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: mDarkBrown),
        ),
      ],
    );
  }
}
