import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mona_coffee/core/utils/common.dart';

class DeliveryMethodSelector extends StatefulWidget {
  final Function(String) onMethodSelected;
  final String currentMethod;

  const DeliveryMethodSelector({
    super.key,
    required this.onMethodSelected,
    required this.currentMethod,
  });

  @override
  State<DeliveryMethodSelector> createState() => _DeliveryMethodSelectorState();
}

class _DeliveryMethodSelectorState extends State<DeliveryMethodSelector> {
  late String selectedMethod;

  @override
  void initState() {
    super.initState();
    selectedMethod =
        widget.currentMethod;
  }

  void _handleMethodSelection(String method) {
    setState(() {
      selectedMethod = method;
    });
  }

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
            svgPath: 'assets/icons/delivery_icon.svg',
            label: 'Delivery',
            isSelected: selectedMethod == 'Delivery',
            onTap: () => _handleMethodSelection('Delivery'),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            svgPath: 'assets/icons/take_away_icon.svg',
            label: 'Take-away',
            isSelected: selectedMethod == 'Take-away',
            onTap: () => _handleMethodSelection('Take-away'),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            svgPath: 'assets/icons/dine_in_icon.svg',
            label: 'Dine-in',
            isSelected: selectedMethod == 'Dine-in',
            onTap: () => _handleMethodSelection('Dine-in'),
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
                    onPressed: () {
                      widget.onMethodSelected(
                          selectedMethod);
                      Navigator.pop(context);
                    },
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
    required String svgPath,
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
              SvgPicture.asset(
                svgPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? mBrown : Colors.grey,
                  BlendMode.srcIn,
                ),
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
