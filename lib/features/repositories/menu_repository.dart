import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mona_coffee/models/menu_item_model.dart';

class MenuRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MenuItem>> getMenuItems(String category) async {
    try {
      if (category == 'Popular') {
        // Get all menu items
        final QuerySnapshot snapshot =
            await _firestore.collection('menu').get();
        final List<MenuItem> allItems = snapshot.docs
            .map((doc) => MenuItem.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        // Randomly select 6 items
        if (allItems.length <= 6) return allItems;

        final random = Random();
        final List<MenuItem> popularItems = [];
        final Set<int> selectedIndices = {};

        while (selectedIndices.length < 6) {
          selectedIndices.add(random.nextInt(allItems.length));
        }

        for (final index in selectedIndices) {
          popularItems.add(allItems[index]);
        }

        return popularItems;
      } else {
        // Get items by category
        final QuerySnapshot snapshot = await _firestore
            .collection('menu')
            .where('category', isEqualTo: category.toLowerCase())
            .get();

        return snapshot.docs
            .map((doc) => MenuItem.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch menu items: $e');
    }
  }
}
