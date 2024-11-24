import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/blocs/favorite/favorite_bloc.dart';
import 'package:mona_coffee/features/blocs/favorite/favorite_event.dart';
import 'package:mona_coffee/features/blocs/favorite/favorite_state.dart';
import 'package:mona_coffee/features/repositories/favorite_repository.dart';

class UpdateOrderScreen extends StatefulWidget {
  const UpdateOrderScreen({super.key});

  @override
  State<UpdateOrderScreen> createState() => _UpdateOrderScreenState();
}

class _UpdateOrderScreenState extends State<UpdateOrderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoriteBloc>().add(
          const CheckFavoriteStatus(
            name: 'Mocha Latte',
            type: 'Ice/Hot',
          ),
        );
  }
  
  Future<void> _toggleFavorite(bool isFavorite) async {
    final bloc = context.read<FavoriteBloc>();

    if (isFavorite) {
      final repository = context.read<FavoriteRepository>();
      final docId = await repository.getFavoriteId('Mocha Latte', 'Ice/Hot');
      if (docId != null) {
        bloc.add(RemoveFromFavorites(docId));
      }
    } else {
      bloc.add(
        const AddToFavorites(
          name: 'Mocha Latte',
          type: 'Ice/Hot',
          image: 'assets/images/coffee.png',
        ),
      );
    }
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
            onPressed: () => context.goNamed('home'),
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
            padding: const EdgeInsets.only(right: 22.0),
            child: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                final isFavorite = state is FavoriteStatus && state.isFavorite;
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: mDarkBrown,
                    size: 24,
                  ),
                  onPressed: () => _toggleFavorite(isFavorite),
                );
              },
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mocha Latte',
                          style: TextStyle(
                            color: mDarkBrown,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.remove_circle_outline,
                              color: mDarkBrown,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
                              child: Text(
                                '1',
                                style: TextStyle(
                                    color: mDarkBrown,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Icon(
                              Icons.add_circle_outline,
                              color: mDarkBrown,
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
                        _buildSizeButton('S', false),
                        const SizedBox(width: 8),
                        _buildSizeButton('M', true),
                        const SizedBox(width: 8),
                        _buildSizeButton('L', false),
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
                        'Update to Cart',
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
    );
  }
}
