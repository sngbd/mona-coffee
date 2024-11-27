import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class AdminDineInOrderDetailScreen extends StatefulWidget {
  const AdminDineInOrderDetailScreen({super.key});

  @override
  State<AdminDineInOrderDetailScreen> createState() =>
      _AdminDineInOrderDetailScreenState();
}

class _AdminDineInOrderDetailScreenState
    extends State<AdminDineInOrderDetailScreen> {
  String seatNumber = '3A';
  bool isEditing = false;
  final TextEditingController _seatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seatController.text = seatNumber;
  }

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: mBrown),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Customer name: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                        Text(
                          'Lorenzo',
                          style: TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                          '08/09/2024',
                          style: TextStyle(color: mDarkBrown),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: mBrown),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: mDarkBrown,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Less ice, less sugar',
                        style: TextStyle(color: mDarkBrown),
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
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1x Mocha Latte',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: mDarkBrown,
                              ),
                            ),
                            Text(
                              'Hot',
                              style: TextStyle(color: mDarkBrown),
                            ),
                            Text(
                              'Medium',
                              style: TextStyle(color: mDarkBrown),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    // Price Summary
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(color: mDarkBrown),
                        ),
                        Text(
                          'Rp 50.000',
                          style: TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Fee',
                          style: TextStyle(color: mDarkBrown),
                        ),
                        Text(
                          'Rp 15.000',
                          style: TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Other Fee',
                          style: TextStyle(color: mDarkBrown),
                        ),
                        Text(
                          'Rp 2.000',
                          style: TextStyle(color: mDarkBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                        Text(
                          'Rp 67.000',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Payment Method and Button
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Pay with Gopay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: mDarkBrown,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Processed Order',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
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
