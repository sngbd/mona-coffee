import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_edit_menu.dart';
import 'package:mona_coffee/features/home/data/entities/menu_item.dart';

class AdminItemDetail extends StatefulWidget {
  final MenuItem menuItem;

  const AdminItemDetail({
    super.key,
    required this.menuItem,
  });

  @override
  State<AdminItemDetail> createState() => _AdminItemDetailState();
}

class _AdminItemDetailState extends State<AdminItemDetail> {
  bool isHotSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mLightPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: mDarkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Detail',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menu')
            .doc(widget.menuItem.name)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: mDarkBrown),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Menu item not found'),
            );
          }

          // Convert Firestore data to MenuItem
          final updatedMenuItem = MenuItem(
            name: snapshot.data!['name'] ?? widget.menuItem.name,
            description: snapshot.data!['description'] ?? widget.menuItem.description,
            smallPrice: snapshot.data!['smallPrice'] ?? widget.menuItem.smallPrice,
            mediumPrice: snapshot.data!['mediumPrice'] ?? widget.menuItem.mediumPrice,
            largePrice: snapshot.data!['largePrice'] ?? widget.menuItem.largePrice,
            stock: snapshot.data!['stock'] ?? widget.menuItem.stock,
            hotImage: snapshot.data!['hotImage'] ?? widget.menuItem.hotImage,
            iceImage: snapshot.data!['iceImage'] ?? widget.menuItem.iceImage,
            rating: widget.menuItem.rating,  // These remain unchanged
            ratingCount: widget.menuItem.ratingCount, category: '',
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        isHotSelected
                            ? widget.menuItem.hotImage
                            : widget.menuItem.iceImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, size: 50, color: mDarkBrown),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            // Jika loading selesai, tampilkan gambar
                            return child;
                          }
                          // Tampilkan indikator loading selama proses
                          return const Center(
                            child: CircularProgressIndicator(
                              color: mDarkBrown,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Title
                  Text(
                    toTitleCase(updatedMenuItem.name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ratings Section
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${updatedMenuItem.rating}',
                        style: const TextStyle(
                          color: mDarkBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${updatedMenuItem.ratingCount} ratings)',
                        style: const TextStyle(
                          color: mDarkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Section
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    updatedMenuItem.description,
                    style: const TextStyle(
                      color: mDarkBrown,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options Section
                  const Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildOptionsButtons(updatedMenuItem),
                  const SizedBox(height: 24),

                  // Size Section
                  const Text(
                    'Size available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Size Options
                  _buildSizeOption(
                      'S', 'Rp ${updatedMenuItem.smallPrice.toString()}'),
                  const SizedBox(height: 8),
                  _buildSizeOption(
                      'M', 'Rp ${updatedMenuItem.mediumPrice.toString()}'),
                  const SizedBox(height: 8),
                  _buildSizeOption(
                      'L', 'Rp ${updatedMenuItem.largePrice.toString()}'),
                  const SizedBox(height: 24),

                  // Stocks Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stocks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mDarkBrown,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${updatedMenuItem.stock} items',
                            style: const TextStyle(
                              color: mDarkBrown,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: mBrown,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminEditMenu(
                                          menuItem: updatedMenuItem)),
                                );
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      )
    );
  }

  Widget _buildOptionsButtons(dynamic updatedMenuItem) {
    return Row(
      children: [
        if (updatedMenuItem.hotImage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildOptionButton(
                'Hot', isHotSelected && widget.menuItem.hotImage.isNotEmpty),
          ),
        if (widget.menuItem.iceImage.isNotEmpty)
          _buildOptionButton(
              'Ice', !isHotSelected && widget.menuItem.iceImage.isNotEmpty),
      ],
    );
  }

  Widget _buildOptionButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isHotSelected = text == 'Hot';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? mBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: mBrown),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : mBrown,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOption(String size, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: mDarkBrown),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            size,
            style: const TextStyle(
              color: mDarkBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: mDarkBrown,
            ),
          ),
        ],
      ),
    );
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
