// lib/features/profile/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:palm_diagnose/core/services/user_service.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';
import 'package:palm_diagnose/features/profile/widgets/profile_input_field.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:palm_diagnose/features/profile/widgets/shimmer/profile_input_field_shimmer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  final _userService = UserService();
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
    setState(() => _isLoading = true);

    final data = await _userService.getCurrentUserData();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted && data != null) {
      setState(() {
        _usernameController.text = data['displayName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _luasTanahController.text = data['luasTanah']?.toString() ?? '';
        _jumlahPohonController.text = data['jumlahPohon']?.toString() ?? '';
        _photoURL = data['photoURL'];
        _isLoading = false;
      });
    }
  }

  bool _validateInputs() {
    if (_usernameController.text.trim().length < 3 ||
        _phoneController.text.trim().isEmpty) {
      _showAwesomeDialog(
        title: 'Peringatan',
        message: '❗ Nama minimal 3 karakter dan nomor telepon wajib diisi',
        type: DialogType.warning,
      );
      return false;
    }

    if (_phoneController.text.length < 10 ||
        _phoneController.text.length > 15) {
      _showAwesomeDialog(
        title: 'Peringatan',
        message: '❗ Nomor telepon tidak valid',
        type: DialogType.warning,
      );
      return false;
    }

    int? luasTanah = int.tryParse(_luasTanahController.text);
    int? jumlahPohon = int.tryParse(_jumlahPohonController.text);

    if (luasTanah == null ||
        luasTanah <= 0 ||
        jumlahPohon == null ||
        jumlahPohon < 0) {
      _showAwesomeDialog(
        title: 'Gagal',
        message: 'Masukkan angka yang valid untuk luas tanah dan jumlah pohon',
        type: DialogType.warning,
      );
      return false;
    }

    return true;
  }

  Future<bool> _updatePasswordIfNeeded() async {
    if (isGoogleSignIn) return true;

    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if ((newPassword.isEmpty && confirmPassword.isEmpty) ||
        (newPassword == '******' && confirmPassword == '******')) {
      return true;
    }

    if (newPassword != confirmPassword) {
      _showAwesomeDialog(
        title: 'Peringatan',
        message: '❗ Password tidak sama',
        type: DialogType.warning,
      );
      return false;
    }

    if (newPassword.length < 6) {
      _showAwesomeDialog(
        title: 'Peringatan',
        message: '❗ Password minimal 6 karakter',
        type: DialogType.warning,
      );
      return false;
    }

    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      _showAwesomeDialog(
        title: 'Berhasil',
        message: '🔐 Password berhasil diperbarui',
        type: DialogType.success,
      );
      _passwordController.clear();
      _confirmPasswordController.clear();
      return true;
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? 'Silakan login ulang untuk mengubah password.'
          : 'Gagal memperbarui password.';
      _showAwesomeDialog(
        title: 'Gagal',
        message: message,
        type: DialogType.error,
      );
      return false;
    } catch (_) {
      _showAwesomeDialog(
        title: 'Error',
        message: 'Terjadi kesalahan tak terduga.',
        type: DialogType.error,
      );
      return false;
    }
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showAwesomeDialog(
        title: 'Gagal',
        message: 'User tidak ditemukan',
        type: DialogType.error,
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
      await _userService.updateUserProfile(uid, updatedData);
      _showAwesomeDialog(
        title: 'Berhasil',
        message: 'Profil berhasil diperbarui',
        type: DialogType.success,
      );
      _loadUserData();
    } catch (_) {
      _showAwesomeDialog(
        title: 'Gagal',
        message: 'Terjadi kesalahan saat menyimpan',
        type: DialogType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAwesomeDialog({
    required String title,
    required String message,
    required DialogType type,
  }) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.bottomSlide,
      title: title,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              ..._buildFormFields(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: ClipOval(
          child: SizedBox(
            width: 100,
            height: 100,
            child: (_photoURL != null && _photoURL!.isNotEmpty)
                ? Image.network(
                    _photoURL!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_avatar.jpg',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/default_avatar.jpg',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(
              label: 'Username',
              controller: _usernameController,
            ),
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(
              label: 'Email',
              controller: _emailController,
              enabled: false,
            ),
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(
              label: 'No. Telepon',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(label: 'Alamat', controller: _alamatController),
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(
              label: 'Luas Tanah (m²)',
              controller: _luasTanahController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(
              label: 'Jumlah Pohon',
              controller: _jumlahPohonController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(
              label: isGoogleSignIn
                  ? 'Password (akun Google)'
                  : 'Password Baru',
              controller: _passwordController,
              obscureText: true,
              enabled: !isGoogleSignIn,
              hintText: '••••••',
            ),
      _isLoading
          ? const ProfileInputFieldShimmer()
          : ProfileInputField(
              label: 'Konfirmasi Password',
              controller: _confirmPasswordController,
              obscureText: true,
              enabled: !isGoogleSignIn,
              hintText: '••••••',
            ),
    ];
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
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
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: 'Keluar',
      desc: 'Yakin ingin logout?',
      btnCancelText: 'Batal',
      btnOkText: 'Logout',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await AuthController().logout();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/auth');
      },
    ).show();
  }
}
