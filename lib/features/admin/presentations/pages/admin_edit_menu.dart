import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class AdminEditMenu extends StatefulWidget {
  const AdminEditMenu({super.key});

  @override
  State<AdminEditMenu> createState() => _AdminEditMenuState();
}

class _AdminEditMenuState extends State<AdminEditMenu> {
  int stockCount = 156;
  bool isIceSelected = true;
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
              // Image and Upload Button
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/coffee.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Upload image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: mBrown,
                        side: const BorderSide(color: mBrown),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reorganize Section
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
                decoration: BoxDecoration(
                  border: Border.all(color: mBrown),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  children: [
                    // Menu Name
                    _buildFormRow(
                      'Menu name',
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'Mocha Latte',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // Description
                    _buildFormRow(
                      'Description',
                      const TextField(
                        decoration: InputDecoration(
                          hintText:
                              'Our Mocha Latte blends rich espresso with velvety steamed milk,...',
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

                    // Size available
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: mDarkBrown)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Size available',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildSizeOption('S', 'Rp 40.000'),
                          const SizedBox(height: 8),
                          _buildSizeOption('M', 'Rp 50.000'),
                          const SizedBox(height: 8),
                          _buildSizeOption('L', 'Rp 60.000'),
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
                            onPressed: () => setState(() {
                              if (stockCount > 0) stockCount--;
                            }),
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String size, String price) {
    return Row(
      children: [
        Checkbox(
          value: true,
          onChanged: (value) {},
          activeColor: mBrown,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: mDarkBrown),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(size),
        ),
        const SizedBox(width: 8),
        Text(price),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Edit',
            style: TextStyle(color: mDarkBrown),
          ),
        ),
      ],
    );
  }
}
