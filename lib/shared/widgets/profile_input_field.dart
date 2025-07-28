import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileInputField extends StatefulWidget {
  final String label;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            obscureText: _obscure,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: InputBorder.none,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Color(0xFF6C7278),
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             letterSpacing: -0.24,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: ShapeDecoration(
//             color: enabled ? Colors.white : const Color(0xFFF3F4F6),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//               side: const BorderSide(color: Color(0xFFEDF1F3)),
//             ),
//             shadows: const [
//               BoxShadow(
//                 color: Color(0x3DE4E5E7),
//                 blurRadius: 2,
//                 offset: Offset(0, 1),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: controller,
//             enabled: enabled,
//             keyboardType: keyboardType,
//             inputFormatters: inputFormatters,
//             obscureText: obscureText,
//             style: const TextStyle(fontSize: 14),
//             decoration: const InputDecoration(
//               isDense: true,
//               contentPadding: EdgeInsets.symmetric(
//                 vertical: 14,
//                 horizontal: 14,
//               ),
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
