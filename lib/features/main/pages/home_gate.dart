// lib/features/main/pages/home_gate.dart
import 'package:flutter/material.dart';
import 'package:palm_diagnose/core/utils/user_utils.dart';
import 'package:palm_diagnose/features/main/pages/home_page.dart';
import 'package:palm_diagnose/features/main/widgets/loading_animation.dart';

class HomeGate extends StatefulWidget {
  final String role;

  const HomeGate({super.key, required this.role});

  @override
  State<HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<HomeGate> {
  bool _isLoading = true;
  late final String _displayName;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final result = await UserUtils.loadUserInfo(widget.role);
    if (!mounted) return;
    setState(() {
      _displayName = result['name'];
      _photoUrl = result['photoUrl'];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingAnimation());
    }

    return HomePage(role: widget.role, initialIndex: 0);
  }
}
