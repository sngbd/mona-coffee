import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mona_coffee/features/home/data/entities/menu_item.dart';

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

  Future<MenuItem> getMenuItem(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('menu').doc(id).get();
      if (doc.exists) {
        return MenuItem.fromFirestore(
            doc.id, doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Menu item not found');
      }
    } catch (e) {
      throw Exception('Failed to load menu item: $e');
    }
  }

  Future<List<MenuItem>> searchMenuItems(String query) async {
    query = query.toLowerCase();
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('menu')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs
          .map((doc) => MenuItem.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }
}
