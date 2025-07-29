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

  static const primaryColor = Color(0xff9333ea);
  static const borderColor = Color(0xffe0e0e0);
  static const errorColor = Color(0xffEF4444);
  static const backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        style: const TextStyle(
          fontSize: 14,
          color: Color.fromARGB(255, 126, 126, 126),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? '',
          isDense: true, // mengecilkan tinggi
          filled: true,
          fillColor: backgroundColor,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelText: widget.label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 94, 94, 94)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 187, 187, 187),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 72, 204, 39),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: errorColor),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;

                      // Hapus ****** saat toggle ke show
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
