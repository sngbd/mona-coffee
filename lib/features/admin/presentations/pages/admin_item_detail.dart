import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class AdminItemDetail extends StatelessWidget {
  const AdminItemDetail({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/coffee.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Mocha Latte',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mDarkBrown,
                ),
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
              const Text(
                'Our Mocha Latte blends rich espresso with velvety steamed milk, premium cocoa, and a hint of vanilla, topped with a smooth layer of foam for a perfectly balanced, indulgent treat.',
                style: TextStyle(
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
              const Row(
                children: [
                  Text('Ice', style: TextStyle(color: mDarkBrown)),
                  Text(' | ', style: TextStyle(color: mDarkBrown)),
                  Text('Hot', style: TextStyle(color: mDarkBrown)),
                ],
              ),
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

              // Size Options
              _buildSizeOption('S', 'Rp 40.000'),
              const SizedBox(height: 8),
              _buildSizeOption('M', 'Rp 50.000'),
              const SizedBox(height: 8),
              _buildSizeOption('L', 'Rp 60.000'),
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
                      const Text(
                        '156 items',
                        style: TextStyle(
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
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOption(String size, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
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
}
