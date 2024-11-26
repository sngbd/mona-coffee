import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/repositories/favorite_repository.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  String selectedSize = 'M';
  int quantity = 1;
  bool isFavorite = false;
  String? favoriteId;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final status =
          await _favoriteRepository.isFavorite('Mocha Latte', 'Ice/Hot');
      if (status) {
        favoriteId =
            await _favoriteRepository.getFavoriteId('Mocha Latte', 'Ice/Hot');
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
        // Remove from favorites
        if (favoriteId != null) {
          await _favoriteRepository.removeFromFavorites(favoriteId!);
          setState(() {
            isFavorite = false;
            favoriteId = null;
          });
          _showSnackBar('Removed from favorites');
        }
      } else {
        // Add to favorites
        await _favoriteRepository.addToFavorites(
          'Mocha Latte',
          'Ice/Hot',
          'assets/images/coffee.png',
        );
        setState(() {
          isFavorite = true;
        });
        // Get the new favorite ID
        favoriteId = await _favoriteRepository.getFavoriteId(
            'Mocha Latte', 'Ice/Hot'); // Ubah 'Ice' menjadi 'Ice/Hot'
        _showSnackBar('Added to favorites');
      }
    } catch (e) {
      _showSnackBar('Error updating favorite status');
    }
  }

  void _onSizeSelected(String size) {
    setState(() {
      selectedSize = size;
    });
  }

  // Tambahkan fungsi untuk mengubah quantity
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
            onPressed: () {
              Navigator.pop(context);
            },
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
        // Tambahkan SafeArea
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
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/coffee.png',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mocha Latte',
                          style: TextStyle(
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

                    // Ice/Hot option
                    const Text(
                      'Ice/Hot',
                      style: TextStyle(
                        color: mDarkBrown,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),
                    // Rating
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 24),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            color: mDarkBrown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (250)',
                          style: TextStyle(
                            color: mDarkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: mDarkBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our Mocha Latte blends rich espresso with velvety steamed milk, premium cocoa, and a hint of vanilla, topped with a smooth layer of foam for a perfectly balanced, indulgent treat.',
                      style: TextStyle(
                        color: mDarkBrown,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Size Selection
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            color: mDarkBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rp 50k',
                          style: TextStyle(
                            color: mBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
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

  Widget _buildSizeButton(String size, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        // Tambahkan GestureDetector
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
