import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:mona_coffee/features/admin/data/repositories/admin_orders_repository.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_dinein_order_detail_screen.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool _isOngoing = true;
  bool _isLoading = false;
  String? _loadingOrderId;
  final AdminOrdersRepository _repository = AdminOrdersRepository();

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _navigateToOrderDetail(
      BuildContext context, Map<String, dynamic> orderData, String orderId) {
    if (orderData['status'] == 'pending' ||
        orderData['status'] == 'processing' ||
        orderData['status'] == 'completed' ||
        orderData['status'] == 'cancelled') {
      final method = orderData['orderType'] as String;
      if (method.toLowerCase() == 'dine-in') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDineInOrderDetailScreen(
              orderData: {
                ...orderData,
                'orderId': orderId,
              },
              ordersRepository: _repository,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOrderDetailScreen(orderData: orderData),
          ),
        );
      }
    }
  }

  Future<void> _showCancellationDialog(String orderId, String userId) async {
    final TextEditingController reasonController = TextEditingController();
    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title:
              const Text('Cancel Order', style: TextStyle(color: mDarkBrown)),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason for cancellation',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: mBrown)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, reasonController.text),
              child: const Text('Submit', style: TextStyle(color: mBrown)),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty) {
      _updateOrderStatus(orderId, userId, 'cancelled', reason);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String userId, String status,
      [String? reason]) async {
    setState(() {
      _loadingOrderId = orderId;
      _isLoading = true;
    });
    try {
      await _repository.updateOrderStatus(orderId, userId, status, reason);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _loadingOrderId = null;
        _isLoading = false;
      });
    }
  }

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
                child: StreamBuilder<QuerySnapshot>(
                  stream: _repository.getOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada order',
                          style: TextStyle(
                            fontSize: 16,
                            color: mDarkBrown,
                          ),
                        ),
                      );
                    }

                    final orders = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final status = data['status'] as String;
                      return _isOngoing
                          ? status == 'pending' || status == 'processing'
                          : status == 'completed' || status == 'cancelled';
                    }).toList();

                    if (orders.isEmpty) {
                      return Center(
                        child: Text(
                          _isOngoing
                              ? 'Tidak ada order aktif'
                              : 'Tidak ada order selesai',
                          style: const TextStyle(
                            fontSize: 16,
                            color: mDarkBrown,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // Mengambil QueryDocumentSnapshot langsung dari orders
                        final doc = orders[index];
                        final orderData = doc.data() as Map<String, dynamic>;
                        final items = (orderData['items'] as List)
                            .cast<Map<String, dynamic>>();
                        final userId = orderData['userId'] as String;

                        return GestureDetector(
                          onTap: () => _navigateToOrderDetail(
                              context, orderData, doc.id),
                          child: _buildOrderCard(
                            items: items,
                            date: DateFormat('dd/MM/yyyy').format(
                              (orderData['createdAt'] as Timestamp).toDate(),
                            ),
                            payment: orderData['paymentMethod'] as String,
                            method: orderData['orderType'] as String,
                            status: orderData['status'] as String,
                            showAcceptButton: orderData['status'] == 'pending',
                            orderId: doc.id,
                            userId: userId,
                          ),
                        );
                      },
                    );
                  },
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

  Widget _buildOrderCard({
    required List<Map<String, dynamic>> items,
    required String date,
    required String payment,
    required String method,
    required String status,
    required bool showAcceptButton,
    required String orderId,
    required String userId,
  }) {
    final bool isProcessingThisOrder = _loadingOrderId == orderId && _isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order info header
            Text(
              'Order Date: $date',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: mDarkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment: $payment',
              style: const TextStyle(
                fontSize: 14,
                color: mDarkBrown,
              ),
            ),
            Text(
              'Method: $method',
              style: const TextStyle(
                fontSize: 14,
                color: mDarkBrown,
              ),
            ),
            Text(
              'Status: $status',
              style: const TextStyle(
                fontSize: 14,
                color: mDarkBrown,
              ),
            ),
            const SizedBox(height: 12),

            // List of ordered items
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item['imageUrl'] != null
                            ? Image.network(
                                item['imageUrl'] as String,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toTitleCase(item['name'] as String),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: mDarkBrown,
                              ),
                            ),
                            Text(
                              '${item['size']} ${item['type']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: mDarkBrown,
                              ),
                            ),
                            Text(
                              'Quantity: ${item['quantity']}x',
                              style: const TextStyle(
                                fontSize: 12,
                                color: mDarkBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

            // Action button
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == 'processing') ...[
                    ElevatedButton(
                      onPressed: isProcessingThisOrder
                          ? null
                          : () =>
                              _updateOrderStatus(orderId, userId, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isProcessingThisOrder
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Finish Order',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                  if (status == 'pending') ...[
                    ElevatedButton(
                      onPressed: isProcessingThisOrder
                          ? null
                          : () => _showCancellationDialog(orderId, userId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isProcessingThisOrder
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Cancel Order',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isProcessingThisOrder
                          ? null
                          : () =>
                              _updateOrderStatus(orderId, userId, 'processing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isProcessingThisOrder
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accept Order',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
