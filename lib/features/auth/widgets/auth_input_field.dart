import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // diperlukan untuk FilteringTextInputFormatter

class AuthInputField extends StatelessWidget {
  final String label;
  final String? hintText; // nullable, boleh tidak diisi

  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final String? Function(String?)? validator; // ✅ Tambahkan ini

  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.toggleVisibility,
    this.validator, // ✅ Tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6C7278),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFEDF1F3), width: 1),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3DE4E5E7),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator, // ✅ Tambahkan ini
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1C1E),
            ),
            decoration: InputDecoration(
              hintText: hintText ?? '',
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C7278),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: toggleVisibility,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
