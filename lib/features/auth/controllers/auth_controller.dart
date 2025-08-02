// import 'package:palm_diagnose/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:palm_diagnose/core/services/user_service.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();

  Future<String?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _userService.saveUserToFirestore(result.user!);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Terjadi kesalahan saat login.';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Login dibatalkan';

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      await _userService.saveUserToFirestore(result.user!);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal login dengan Google.';
    }
  }

  Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();

      // Cek apakah user login dengan Google
      final isSignedIn = await googleSignIn.isSignedIn();
      if (isSignedIn) {
        await googleSignIn.disconnect(); // Putuskan sesi token
        await googleSignIn.signOut(); // Logout Google
      }

      await FirebaseAuth.instance.signOut(); // Logout Firebase terakhir
      if (kDebugMode) {
        print('Logout berhasil.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
  }

  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Email dan password tidak boleh kosong.';
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan ke Firestore
      final user = result.user!;
      await _userService.saveUserToFirestore(
        user,
        additionalData: {'username': username, 'phone': phone},
      );

      await user.sendEmailVerification(); // opsional
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email sudah digunakan. Gunakan email lain.';
      }
      return e.message;
    } catch (_) {
      return 'Terjadi kesalahan saat mendaftar.';
    }
  }
}
