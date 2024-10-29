import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, String>> favorites = List.generate(
    6,
    (index) => {
      'name': 'Mocha Latte',
      'type': 'Ice/Hot',
      'image': 'assets/images/coffee.png',
    },
  );

  FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Favorite',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        itemBuilder: (context, index) => _buildFavoriteItem(favorites[index]),
      ),
    );
  }

  Widget _buildFavoriteItem(Map<String, String> coffee) {
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
                coffee['image']!,
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
                    coffee['name']!,
                    style: const TextStyle(
                      color: mBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    coffee['type']!,
                    style: const TextStyle(color: mBrown),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mBrown,
                      minimumSize: const Size(100, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Order again',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.brown),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
