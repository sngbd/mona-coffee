import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/helper.dart';
import 'package:mona_coffee/core/utils/sizer.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/cart_bloc.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/checkout_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/item_detail_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/order_screen.dart';
import 'package:mona_coffee/features/home/data/entities/menu_option.dart';
import 'package:mona_coffee/features/home/data/repositories/menu_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with WidgetsBindingObserver {
  late CartBloc _cartBloc;
  bool _isOngoing = true;
  List<Map<String, dynamic>> pastOrders = [];
  bool isLoadingPastOrders = true;

  @override
  void initState() {
    super.initState();
    _cartBloc = context.read<CartBloc>();
    WidgetsBinding.instance.addObserver(this);
    _loadCart();
  }

  Future<void> _fetchPastOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final transactionsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('user-transactions')
            .orderBy('orderTime', descending: true)
            .get();
        setState(() {
          pastOrders = transactionsSnapshot.docs.map((doc) {
            final data = doc.data();
            data['orderId'] = doc.id;
            return data;
          }).toList();
          isLoadingPastOrders = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingPastOrders = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCart();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null && currentRoute.isCurrent) {
      _loadCart();
    }
  }

  void _loadCart() {
    _cartBloc.add(LoadCart());
    _fetchPastOrders();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);

    return RefreshIndicator(
      color: mDarkBrown,
      backgroundColor: Colors.white,
      onRefresh: () async {
        context.read<CartBloc>().add(LoadCart());
      },
      child: Scaffold(
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: mDarkBrown));
                } else if (state is CartError) {
                  return Column(
                    children: [
                      _buildToggle(),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: Sizer.screenHeight * 0.65,
                        child: Center(
                          child: Text(
                            'Error: ${state.message}',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is CartLoaded) {
                  if (!_isOngoing) {
                    return _buildPastOrders();
                  }
                  final cartItems = state.items;
                  if (cartItems.isEmpty) {
                    return Column(
                      children: [
                        _buildToggle(),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: Sizer.screenHeight * 0.65,
                          child: const Center(
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildToggle(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(cartItems[index]);
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: Text('Loading cart...'));
              },
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoaded && state.items.isNotEmpty) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                label: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                backgroundColor: mBrown,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Widget _buildOrderCard(CartItem cart) {
    return GestureDetector(
      onTap: () async {
        MenuRepository menuRepository = MenuRepository();
        final item = await menuRepository.getMenuItem(cart.name);
        MenuOption option = MenuOption(type: cart.type, size: cart.size);
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              item: item,
              option: option,
            ),
          ),
        );
      },
      child: Card(
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
                child: Image.network(
                  cart.imageUrl,
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
                      Helper().toTitleCase(cart.name),
                      style: const TextStyle(
                        color: mBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cart.type,
                      style: const TextStyle(color: mBrown),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      cart.size,
                      style: const TextStyle(color: mBrown),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${cart.quantity}x',
                      style: const TextStyle(color: mBrown),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: mBrown),
                onPressed: () => context.read<CartBloc>().add(
                      RemoveFromCart(cart.compositeKey),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastOrders() {
    if (isLoadingPastOrders) {
      return const Center(child: CircularProgressIndicator());
    }
    if (pastOrders.isEmpty) {
      return Column(
        children: [
          _buildToggle(),
          const SizedBox(height: 20),
          SizedBox(
            height: Sizer.screenHeight * 0.65,
            child: const Center(
              child: Text(
                'You have no past orders',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggle(),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pastOrders.length,
            itemBuilder: (context, index) {
              final order = pastOrders[index];
              final items = order['items'];
              final firstItem = items.isNotEmpty ? items[0] : null;
              final moreItemsCount = items.length - 1;

              return GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderScreen(
                        order: order,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        if (firstItem != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              firstItem['imageUrl'],
                              width: 125,
                              height: 125,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTimestamp(order['orderTime']),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                Helper().toTitleCase(firstItem['name']),
                                style: const TextStyle(
                                  color: mBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                firstItem['type'],
                                style: const TextStyle(color: mBrown),
                              ),
                              Text(
                                firstItem['size'],
                                style: const TextStyle(color: mBrown),
                              ),
                              Text(
                                '${firstItem['quantity']}x',
                                style: const TextStyle(color: mBrown),
                              ),
                              if (moreItemsCount > 0)
                                Text(
                                  '...and $moreItemsCount more items',
                                  style: const TextStyle(
                                    color: mGray200,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12.0,
                                  ),
                                ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Rp${order['totalAmount']}',
                                style: const TextStyle(
                                  color: mDarkBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                Helper().toTitleCase(order['status']),
                                style: TextStyle(
                                  color: order['status'] == 'pending'
                                      ? Colors.grey[600]
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
