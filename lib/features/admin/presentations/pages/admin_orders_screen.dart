import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool _isOngoing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightOrange,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mDarkBrown,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildToggle(),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _buildOrderCard(
                      'Mocha Latte',
                      'Medium Hot',
                      '1x',
                      '08/09/2024',
                      'Gopay',
                      'Delivery',
                      'Unprocessed',
                      true,
                    ),
                    const SizedBox(height: 12),
                    _buildOrderCard(
                      'Mocha Latte',
                      'Small Hot',
                      '1x',
                      '08/09/2024',
                      'OVO',
                      'Delivery',
                      'On process',
                      false,
                    ),
                    const SizedBox(height: 12),
                    _buildOrderCard(
                      'Mocha Latte',
                      'Large Hot',
                      '1x',
                      '08/09/2024',
                      'Gopay',
                      'Delivery',
                      'Unprocessed',
                      true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isOngoing = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: _isOngoing ? mBrown : Colors.transparent,
              border: Border.all(color: mBrown),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ongoing',
              style: TextStyle(
                color: _isOngoing ? Colors.white : mBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              _isOngoing = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: !_isOngoing ? mBrown : Colors.transparent,
              border: Border.all(color: mBrown),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Past Orders',
              style: TextStyle(
                color: !_isOngoing ? Colors.white : mBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(
    String name,
    String size,
    String quantity,
    String date,
    String payment,
    String method,
    String status,
    bool showAcceptButton,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/coffee.png',
                width: 100,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mDarkBrown,
                    ),
                  ),
                  Text(
                    size,
                    style: const TextStyle(
                      fontSize: 12,
                      color: mDarkBrown,
                    ),
                  ),
                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 12,
                      color: mDarkBrown,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: mDarkBrown,
                    ),
                  ),
                  Text(
                    'Payment: $payment',
                    style: const TextStyle(
                      fontSize: 12,
                      color: mDarkBrown,
                    ),
                  ),
                  Text(
                    'Method: $method',
                    style: const TextStyle(
                      fontSize: 12,
                      color: mDarkBrown,
                    ),
                  ),
                  Text(
                    'Status: $status',
                    style: const TextStyle(
                      fontSize: 12,
                      color: mDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 8), // Jarak antara status dan tombol
                  Align(
                    alignment:
                        Alignment.centerRight, // Menempatkan tombol di kanan
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement accept/track order functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        showAcceptButton ? 'Accept order' : 'Track order',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
