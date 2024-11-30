import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/features/home/data/entities/menu_item.dart';

class AdminEditMenu extends StatefulWidget {
  final MenuItem menuItem;

  const AdminEditMenu({
    super.key,
    required this.menuItem,
  });

  @override
  State<AdminEditMenu> createState() => _AdminEditMenuState();
}

class _AdminEditMenuState extends State<AdminEditMenu> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController smallPriceController;
  late TextEditingController mediumPriceController;
  late TextEditingController largePriceController;
  late int stockCount;
  late bool isIceSelected;
  late bool isHotSelected;
  String currentHotImage = '';
  String currentIceImage = '';
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.menuItem.name);
    descriptionController =
        TextEditingController(text: widget.menuItem.description);
    smallPriceController =
        TextEditingController(text: widget.menuItem.smallPrice.toString());
    mediumPriceController =
        TextEditingController(text: widget.menuItem.mediumPrice.toString());
    largePriceController =
        TextEditingController(text: widget.menuItem.largePrice.toString());
    stockCount = widget.menuItem.stock;
    isIceSelected = widget.menuItem.iceImage.isNotEmpty;
    isHotSelected = widget.menuItem.hotImage.isNotEmpty;
    currentHotImage = widget.menuItem.hotImage;
    currentIceImage = widget.menuItem.iceImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    smallPriceController.dispose();
    mediumPriceController.dispose();
    largePriceController.dispose();
    super.dispose();
  }

  Future<String?> pickAndConvertImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      final File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
      return null;
    }
  }

  Future<void> uploadImage(String type) async {
    setState(() => isLoading = true);
    try {
      final String? base64Image = await pickAndConvertImage();
      if (base64Image == null) return;

      // Update Firestore with the new image
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.menuItem.name)
          .update({
        '${type.toLowerCase()}Image': base64Image,
      });

      // Update local state
      setState(() {
        if (type == 'Ice') {
          currentIceImage = base64Image;
        } else {
          currentHotImage = base64Image;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$type image uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading $type image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateMenuItem() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.menuItem.name)
          .update({
        'description': descriptionController.text,
        'stock': stockCount,
        'smallPrice': int.tryParse(smallPriceController.text) ?? 0,
        'mediumPrice': int.tryParse(mediumPriceController.text) ?? 0,
        'largePrice': int.tryParse(largePriceController.text) ?? 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating menu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildImageSection(
      String imageUrl, String type, VoidCallback onUpload) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.startsWith('data:image') || imageUrl.isEmpty
                ? Image.memory(
                    base64Decode(imageUrl.replaceFirst(
                        RegExp(r'data:image/[^;]+;base64,'), '')),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, size: 50, color: mDarkBrown),
                      );
                    },
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, size: 50, color: mDarkBrown),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: isLoading ? null : onUpload, // Use the callback here
          icon: const Icon(Icons.file_upload_outlined, size: 16),
          label: Text(
            'Upload $type image',
            style: const TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: mBrown,
            side: const BorderSide(color: mBrown),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ],
    );
  }

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
          'Edit menu',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Display Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (currentIceImage.isNotEmpty)
                    _buildImageSection(
                        currentIceImage, 'Ice', () => uploadImage('Ice')),
                  if (currentHotImage.isNotEmpty)
                    _buildImageSection(
                        currentHotImage, 'Hot', () => uploadImage('Hot')),
                ],
              ),
              const SizedBox(height: 24),

              // Reorganize Section Title
              Container(
                decoration: const BoxDecoration(
                  color: mBrown,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  'Reorganize here',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Form Container
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(color: mBrown),
                    right: BorderSide(color: mBrown),
                    bottom: BorderSide(color: mBrown),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  children: [
                    // Menu Name
                    _buildFormRow(
                      'Menu name',
                      TextField(
                        controller: nameController,
                        enabled: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // Description
                    _buildFormRow(
                      'Description',
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                    ),

                    // Options
                    _buildFormRow(
                      'Options',
                      Row(
                        children: [
                          Checkbox(
                            value: isIceSelected,
                            onChanged: (value) =>
                                setState(() => isIceSelected = value!),
                            activeColor: mBrown,
                          ),
                          const Text('Ice'),
                          const SizedBox(width: 20),
                          Checkbox(
                            value: isHotSelected,
                            onChanged: (value) =>
                                setState(() => isHotSelected = value!),
                            activeColor: mBrown,
                          ),
                          const Text('Hot'),
                        ],
                      ),
                    ),

                    // Size available with prices
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: mDarkBrown)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Size available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: mDarkBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSizeOption('S', smallPriceController),
                          const SizedBox(height: 8),
                          _buildSizeOption('M', mediumPriceController),
                          const SizedBox(height: 8),
                          _buildSizeOption('L', largePriceController),
                        ],
                      ),
                    ),

                    // Stocks
                    _buildFormRow(
                      'Stocks',
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (stockCount > 0) {
                                setState(() => stockCount--);
                              }
                            },
                          ),
                          Text(
                            stockCount.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => stockCount++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateMenuItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, Widget content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: mDarkBrown)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: mDarkBrown,
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String size, TextEditingController controller) {
    return Row(
      children: [
        Checkbox(
          value: true,
          onChanged: (value) {},
          activeColor: mBrown,
        ),
        SizedBox(
          width: 60,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: mDarkBrown),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                size,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
