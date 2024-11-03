import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/common.dart';

class DeliveryMethodSelector extends StatelessWidget {
  final Function(String) onMethodSelected;

  const DeliveryMethodSelector({
    super.key,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Select purchase type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: mDarkBrown,
            ),
          ),
          const SizedBox(height: 20),
          _buildOptionButton(
            icon: Icons.delivery_dining,
            label: 'Delivery',
            isSelected: true,
            onTap: () => onMethodSelected('Delivery'),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.shopping_bag,
            label: 'Take-away',
            isSelected: false,
            onTap: () => onMethodSelected('Take-away'),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.restaurant,
            label: 'Dine-in',
            isSelected: false,
            onTap: () => onMethodSelected('Dine-in'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: mBrown),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: mBrown),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mBrown,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFCEFE9) : Colors.white,
            border: Border.all(
              color: isSelected ? mBrown : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? mBrown : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? mBrown : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
