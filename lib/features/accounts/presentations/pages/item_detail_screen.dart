// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/widgets/flasher.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item_repo.dart';
import 'package:mona_coffee/features/accounts/data/repositories/cart_repository.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/cart_bloc.dart';
import 'package:mona_coffee/features/home/data/entities/menu_option.dart';
import 'package:mona_coffee/features/home/data/repositories/favorite_repository.dart';
import 'package:mona_coffee/features/home/data/entities/menu_item.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItem item;
  final MenuOption? option;
  const ItemDetailScreen({super.key, required this.item, this.option});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  String selectedSize = 'M';
  int quantity = 1;
  bool isFavorite = false;
  bool isFavoriteLoading = true;
  bool isInCart = false;
  bool isInCartLoading = true;
  String? favoriteId;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final CartRepository _cartRepository = CartRepository();
  late double currentPrice;
  String _selectedOption = 'Hot';

  @override
  void initState() {
    super.initState();
    selectedSize = widget.option?.size ?? 'M';
    _selectedOption = widget.option?.type ?? 'Hot';
    if (selectedSize == 'S') {
      currentPrice = widget.item.smallPrice.toDouble();
    } else if (selectedSize == 'M') {
      currentPrice = widget.item.mediumPrice.toDouble();
    } else {
      currentPrice = widget.item.largePrice.toDouble();
    }
    _checkFavoriteStatus();
    _checkCartStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final status = await _favoriteRepository.isFavorite(
          widget.item.name, _selectedOption, selectedSize);
      if (status) {
        favoriteId = await _favoriteRepository.getFavoriteId(
            widget.item.name, _selectedOption, selectedSize);
      }
      setState(() {
        isFavorite = status;
        isFavoriteLoading = false;
      });
    } catch (e) {
      Flasher.showSnackBar(
        context,
        'Error',
        'Error checking favorite status',
        Icons.error_outline,
        Colors.red,
      );
    }
  }

  Future<void> _checkCartStatus() async {
    setState(() {
      isInCartLoading = true;
    });
    try {
      final qty = await _cartRepository.getQuantityInCart(
          widget.item.name, _selectedOption, selectedSize);
      if (qty > 0) {
        setState(() {
          isInCart = true;
        });
        quantity = qty;
      } else {
        setState(() {
          isInCart = false;
        });
      }
      setState(() {
        isInCartLoading = false;
      });
    } catch (e) {
      setState(() {
        isInCart = false;
        isInCartLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      isFavoriteLoading = true;
    });
    try {
      if (isFavorite) {
        if (favoriteId != null) {
          await _favoriteRepository.removeFromFavorites(favoriteId!);
          setState(() {
            isFavorite = false;
            isFavoriteLoading = false;
            favoriteId = null;
          });
          Flasher.showSnackBar(
            context,
            'Success',
            'Removed from favorites',
            Icons.check_circle_outline,
            Colors.green,
          );
        }
      } else {
        await _favoriteRepository.addToFavorites(
          widget.item.name,
          _selectedOption,
          selectedSize,
          _selectedOption == 'Hot'
              ? widget.item.hotImage
              : widget.item.iceImage,
        );
        setState(() {
          isFavorite = true;
          isFavoriteLoading = false;
        });
        favoriteId = await _favoriteRepository.getFavoriteId(
            widget.item.name, _selectedOption, selectedSize);
        Flasher.showSnackBar(
          context,
          'Success',
          'Added to favorites',
          Icons.check_circle_outline,
          Colors.green,
        );
      }
    } catch (e) {
      Flasher.showSnackBar(
        context,
        'Error',
        'Error updating favorite status',
        Icons.error_outline,
        Colors.red,
      );
    }
  }

  void _onSizeSelected(String size) {
    setState(() {
      selectedSize = size;
      isFavoriteLoading = true;
      // Update price based on selected size
      switch (size) {
        case 'S':
          currentPrice = widget.item.smallPrice.toDouble();
          break;
        case 'M':
          currentPrice = widget.item.mediumPrice.toDouble();
          break;
        case 'L':
          currentPrice = widget.item.largePrice.toDouble();
          break;
      }
    });
    _checkFavoriteStatus();
    _checkCartStatus();
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
      isFavoriteLoading = true;
    });
    _checkFavoriteStatus();
    _checkCartStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightOrange,
      appBar: AppBar(
        backgroundColor: mLightOrange,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: mDarkBrown,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Detail',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          isFavoriteLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 25.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: mDarkBrown,
                      strokeWidth: 3,
                    ),
                  ))
              : Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: mDarkBrown,
                      size: 24,
                    ),
                    onPressed: _toggleFavorite,
                  )),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedOption == 'Hot'
                            ? widget.item.hotImage
                            : widget.item.iceImage,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          toTitleCase(widget.item.name),
                          style: const TextStyle(
                            color: mDarkBrown,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: _decrementQuantity,
                              child: const Icon(
                                Icons.remove_circle_outline,
                                color: mDarkBrown,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  color: mDarkBrown,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _incrementQuantity,
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: mDarkBrown,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectOption('Hot'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOption == 'Hot'
                                ? mBrown
                                : Colors.white,
                          ),
                          child: Text(
                            'Hot',
                            style: TextStyle(
                              color: _selectedOption == 'Hot'
                                  ? Colors.white
                                  : mDarkBrown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _selectOption('Ice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOption == 'Ice'
                                ? mBrown
                                : Colors.white,
                          ),
                          child: Text(
                            'Ice',
                            style: TextStyle(
                              color: _selectedOption == 'Ice'
                                  ? Colors.white
                                  : mDarkBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 24),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.rating.toString(),
                          style: const TextStyle(
                            color: mDarkBrown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${widget.item.totalRatings})',
                          style: const TextStyle(
                            color: mDarkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: mDarkBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.description,
                      style: const TextStyle(
                        color: mDarkBrown,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Size',
                      style: TextStyle(
                        color: mDarkBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSizeButton('S', selectedSize == 'S'),
                        const SizedBox(width: 8),
                        _buildSizeButton('M', selectedSize == 'M'),
                        const SizedBox(width: 8),
                        _buildSizeButton('L', selectedSize == 'L'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Price',
                          style: TextStyle(
                            color: mDarkBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rp ${(currentPrice * quantity).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: mBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    BlocConsumer<CartBloc, CartState>(
                      listener: (context, state) {
                        if (state is CartError) {
                          Flasher.showSnackBar(
                            context,
                            'Error',
                            state.message,
                            Icons.error_outline,
                            Colors.red,
                          );
                        }

                        if (state is CartLoaded) {
                          Flasher.showSnackBar(
                            context,
                            'Success',
                            'Item added to cart',
                            Icons.check_circle_outline,
                            Colors.green,
                          );
                        }
                      },
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: () {
                            final compositeKey =
                                '${widget.item.name}_${_selectedOption}_$selectedSize';
                            final cartItem = CartItemRepo(
                                compositeKey: compositeKey,
                                name: widget.item.name,
                                type: _selectedOption,
                                size: selectedSize,
                                price: currentPrice,
                                quantity: quantity,
                                imageUrl: _selectedOption == 'Hot'
                                    ? widget.item.hotImage
                                    : widget.item.iceImage,
                                timestamp: FieldValue.serverTimestamp());
                            context.read<CartBloc>().add(AddToCart(cartItem));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: state is CartLoading || isInCartLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : (isInCart
                                  ? const Text(
                                      'Update to Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : const Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                        );
                      },
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

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildSizeButton(String size, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onSizeSelected(size),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? mLightPink : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? mBrown : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              size,
              style: TextStyle(
                fontSize: 22,
                color: isSelected ? mBrown : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
