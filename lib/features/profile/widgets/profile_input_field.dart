import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileInputField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.inputFormatters,
    this.hintText,
  });

  @override
  State<ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<ProfileInputField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: isDark ? Colors.grey : Colors.grey[700],
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? '',
          isDense: true,
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelText: widget.label,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: isDark ? Colors.grey : Colors.grey[700],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isDark
                  ? const Color.fromARGB(0, 0, 0, 0)
                  : const Color.fromARGB(0, 255, 255, 255),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isDark
                  ? const Color.fromARGB(43, 117, 117, 117)
                  : const Color.fromARGB(60, 165, 165, 165),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF43A047), // warna hijau elegan
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE53935)),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;

                      if (!_obscure && widget.controller.text == "******") {
                        widget.controller.clear();
                      }
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
