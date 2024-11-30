import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/helper.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/cart_bloc.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/checkout_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/item_detail_screen.dart';
import 'package:mona_coffee/features/home/data/entities/menu_option.dart';
import 'package:mona_coffee/features/home/data/repositories/menu_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isOngoing = true;

  @override
  Widget build(BuildContext context) {
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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (!_isOngoing) {
                return _buildPastOrders();
              }
              if (state is CartLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: mDarkBrown));
              } else if (state is CartError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is CartLoaded) {
                final cartItems = state.items;
                if (cartItems.isEmpty) {
                  return const Center(child: Text('Your cart is empty'));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggle(),
        const Expanded(
          child: Center(
            child: Text(
              'You have no past orders',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
