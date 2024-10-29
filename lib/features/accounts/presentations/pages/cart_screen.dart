import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/models/order_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isOngoing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggle(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index]);
                },
              ),
            ),
          ],
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

  Widget _buildOrderCard(Order order) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                order.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderDate,
                    style: const TextStyle(color: mBrown),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    order.coffeeName,
                    style: const TextStyle(
                      color: mBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    order.type,
                    style: const TextStyle(color: mBrown),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${order.quantity}x',
                    style: const TextStyle(color: mBrown),
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
