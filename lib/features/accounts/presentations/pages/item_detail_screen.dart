import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/repositories/favorite_repository.dart';
import 'package:mona_coffee/models/menu_item_model.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  String selectedSize = 'M';
  int quantity = 1;
  bool isFavorite = false;
  String? favoriteId;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  late double currentPrice;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    // Initialize price based on medium size
    currentPrice = widget.item.mediumPrice.toDouble();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final status = await _favoriteRepository.isFavorite(
          widget.item.name, widget.item.type);
      if (status) {
        favoriteId = await _favoriteRepository.getFavoriteId(
            widget.item.name, widget.item.type);
      }
      setState(() {
        isFavorite = status;
      });
    } catch (e) {
      _showSnackBar('Error checking favorite status');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        if (favoriteId != null) {
          await _favoriteRepository.removeFromFavorites(favoriteId!);
          setState(() {
            isFavorite = false;
            favoriteId = null;
          });
          _showSnackBar('Removed from favorites');
        }
      } else {
        await _favoriteRepository.addToFavorites(
          widget.item.name,
          widget.item.type,
          widget.item.hotImage,
        );
        setState(() {
          isFavorite = true;
        });
        favoriteId = await _favoriteRepository.getFavoriteId(
            widget.item.name, widget.item.type);
        _showSnackBar('Added to favorites');
      }
    } catch (e) {
      _showSnackBar('Error updating favorite status');
    }
  }

  void _onSizeSelected(String size) {
    setState(() {
      selectedSize = size;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightOrange,
      appBar: AppBar(
        backgroundColor: mLightOrange,
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
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: mDarkBrown,
                size: 24,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
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
                    const SizedBox(height: 60),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.item.hotImage,
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
                    Text(
                      widget.item.type,
                      style: const TextStyle(
                        color: mDarkBrown,
                        fontSize: 16,
                      ),
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
                    ElevatedButton(
                      onPressed: () {
                        // Implement add to cart functionality
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
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
