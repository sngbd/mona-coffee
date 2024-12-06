import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/sizer.dart';

class CustomInputField extends StatelessWidget {
  final String label, hint;
  final String? initialValue;
  final double paddingOuterTop;
  final double paddingOuterBottom;
  final void Function(String) onChange;
  final VoidCallback? onPressedSuffix;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool? textArea;
  final bool enabled;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChange,
    required this.paddingOuterTop,
    required this.paddingOuterBottom,
    this.initialValue,
    this.validator,
    this.onPressedSuffix,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textArea,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: paddingOuterBottom,
        top: paddingOuterTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              keyboardType: keyboardType,
              obscureText: obscureText,
              initialValue: initialValue,
              enabled: enabled,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                suffixIcon: suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: IconButton(
                          onPressed: onPressedSuffix,
                          icon: FaIcon(
                            suffixIcon,
                            size: Sizer.screenHeight * 0.02,
                            color: mDarkBrown,
                          ),
                        ),
                      )
                    : null,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              onChanged: (value) => onChange(value),
              validator: validator,
              maxLines: textArea == null ? 1 : null,
            ),
          ),
        ],
      ),
    );
  }
}
