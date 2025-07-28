import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:palm_diagnose/core/services/firebase_service.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';
import 'package:palm_diagnose/shared/widgets/custom_top_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _luasTanahController = TextEditingController();
  final TextEditingController _jumlahPohonController = TextEditingController();

  File? _selectedImage;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final ref =
        FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_usernameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Nama dan nomor telepon wajib diisi')),
      );
      return;
    }

    String? uploadedPhotoURL = _photoURL;
    if (_selectedImage != null) {
      uploadedPhotoURL = await _uploadImage(_selectedImage!);
    }

    final updatedData = {
      'displayName': _usernameController.text,
      'phone': _phoneController.text,
      'alamat': _alamatController.text,
      'luasTanah': int.tryParse(_luasTanahController.text) ?? 0,
      'jumlahPohon': int.tryParse(_jumlahPohonController.text) ?? 0,
      'photoURL': uploadedPhotoURL ?? '',
    };

    try {
      await _firebaseService.updateUserProfile(uid, updatedData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profil berhasil diperbarui')),
      );
      _loadUserData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal memperbarui profil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopAppBar(
        title: _usernameController.text.isEmpty
            ? 'Profil'
            : _usernameController.text,
        upperTitle: 'Profil Pengguna',
        profileImageUrl: _photoURL,
        onTapProfile: () async {
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
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_photoURL != null && _photoURL!.isNotEmpty)
                        ? NetworkImage(_photoURL!) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.jpg'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'No. Telepon'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: _luasTanahController,
              decoration: const InputDecoration(labelText: 'Luas Tanah (m²)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _jumlahPohonController,
              decoration: const InputDecoration(labelText: 'Jumlah Pohon'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
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
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
