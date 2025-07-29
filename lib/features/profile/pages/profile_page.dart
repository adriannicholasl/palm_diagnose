// lib/features/profile/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';
import 'package:palm_diagnose/features/profile/widgets/profile_input_field.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  final _firebaseService = FirebaseService();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alamatController = TextEditingController();
  final _luasTanahController = TextEditingController();
  final _jumlahPohonController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _photoURL;
  late final bool isGoogleSignIn;

  @override
  void initState() {
    super.initState();
    isGoogleSignIn =
        FirebaseAuth.instance.currentUser?.providerData.any(
          (info) => info.providerId == 'google.com',
        ) ??
        false;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _firebaseService.getCurrentUserData();
    if (data != null) {
      setState(() {
        _usernameController.text = data['displayName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _luasTanahController.text = data['luasTanah']?.toString() ?? '';
        _jumlahPohonController.text = data['jumlahPohon']?.toString() ?? '';
        _photoURL = data['photoURL'];
      });
    }
  }

  bool _validateInputs() {
    if (_usernameController.text.trim().length < 3 ||
        _phoneController.text.trim().isEmpty) {
      _showSnackBar('❗ Nama minimal 3 karakter dan nomor telepon wajib diisi');
      return false;
    }

    if (_phoneController.text.length < 10 ||
        _phoneController.text.length > 15) {
      _showSnackBar('❗ Nomor telepon tidak valid');
      return false;
    }

    int? luasTanah = int.tryParse(_luasTanahController.text);
    int? jumlahPohon = int.tryParse(_jumlahPohonController.text);

    if (luasTanah == null ||
        luasTanah <= 0 ||
        jumlahPohon == null ||
        jumlahPohon < 0) {
      _showSnackBar(
        '❗ Masukkan angka yang valid untuk luas tanah dan jumlah pohon',
      );
      return false;
    }

    return true;
  }

  Future<bool> _updatePasswordIfNeeded() async {
    if (isGoogleSignIn) return true;

    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Tambahan: abaikan jika placeholder dummy
    if ((newPassword.isEmpty && confirmPassword.isEmpty) ||
        (newPassword == '******' && confirmPassword == '******')) {
      return true;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('❗ Password tidak sama');
      return false;
    }

    if (newPassword.length < 6) {
      _showSnackBar('❗ Password minimal 6 karakter');
      return false;
    }

    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      _showSnackBar('🔐 Password berhasil diperbarui');
      _passwordController.clear();
      _confirmPasswordController.clear();
      return true;
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? '❗ Silakan login ulang untuk mengubah password.'
          : '❌ Gagal memperbarui password.';
      _showSnackBar(message);
    } catch (_) {
      _showSnackBar('❌ Terjadi kesalahan tak terduga.');
    }
    return false;
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return; // cegah double tap
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showAwesomeSnackbar(
        'Gagal',
        'User tidak ditemukan',
        ContentType.failure,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (!_validateInputs() || !await _updatePasswordIfNeeded()) {
      setState(() => _isLoading = false);
      return;
    }

    final updatedData = {
      'displayName': _usernameController.text,
      'phone': _phoneController.text,
      'alamat': _alamatController.text,
      'luasTanah': int.parse(_luasTanahController.text),
      'jumlahPohon': int.parse(_jumlahPohonController.text),
    };

    try {
      await _firebaseService.updateUserProfile(uid, updatedData);
      _showAwesomeSnackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        ContentType.success,
      );
      _loadUserData();
    } catch (_) {
      _showAwesomeSnackbar(
        'Gagal',
        'Terjadi kesalahan saat menyimpan',
        ContentType.failure,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAwesomeSnackbar(String title, String message, ContentType type) {
    if (!mounted) return;
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        (_photoURL != null && _photoURL!.isNotEmpty)
                        ? NetworkImage(_photoURL!)
                        : const AssetImage('assets/images/default_avatar.jpg')
                              as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  ProfileInputField(
                    label: 'Username',
                    controller: _usernameController,
                  ),
                  ProfileInputField(
                    label: 'Email',
                    controller: _emailController,
                    enabled: false,
                  ),
                  ProfileInputField(
                    label: 'No. Telepon',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  ProfileInputField(
                    label: 'Alamat',
                    controller: _alamatController,
                  ),
                  ProfileInputField(
                    label: 'Luas Tanah (m²)',
                    controller: _luasTanahController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  ProfileInputField(
                    label: 'Jumlah Pohon',
                    controller: _jumlahPohonController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  ProfileInputField(
                    label: isGoogleSignIn
                        ? 'Password (akun Google)'
                        : 'Password Baru',
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !isGoogleSignIn,
                    hintText: '••••••', // ini hanya tampilan, bukan nilai
                  ),
                  ProfileInputField(
                    label: 'Konfirmasi Password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    enabled: !isGoogleSignIn,
                    hintText: '••••••',
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: _buttonStyle(const Color(0xFF3AC35B)),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Simpan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleLogout,
                          style: _buttonStyle(Colors.red),
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthController().logout();

      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }
}
