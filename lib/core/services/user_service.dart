import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Ambil data user yang sedang login
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Ambil semua user sebagai Stream
  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Ambil semua user + jumlah deteksi
  Future<List<Map<String, dynamic>>> getAllUsersWithDetectionCounts() async {
    final usersSnapshot = await _db.collection('users').get();
    final detectionsSnapshot = await _db.collection('detections').get();

    final Map<String, int> detectionCounts = {};
    for (var doc in detectionsSnapshot.docs) {
      final uid = doc['uid'];
      if (uid != null) {
        detectionCounts[uid] = (detectionCounts[uid] ?? 0) + 1;
      }
    }

    return usersSnapshot.docs.map((userDoc) {
      final userData = userDoc.data();
      final uid = userData['uid'];
      return {...userData, 'totalDeteksi': detectionCounts[uid] ?? 0};
    }).toList();
  }

  /// Simpan user ke Firestore (jika belum ada)
  Future<void> saveUserToFirestore(
    User user, {
    Map<String, dynamic>? additionalData,
  }) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? additionalData?['username'] ?? '',
        'photoURL': user.photoURL ?? '',
        'phone': additionalData?['phone'] ?? '',
        'alamat': additionalData?['alamat'] ?? '',
        'luasTanah': additionalData?['luasTanah'] ?? 0,
        'jumlahPohon': additionalData?['jumlahPohon'] ?? 0,
        'lastLogin': Timestamp.now(),
        'role': 'user',
        ...?additionalData,
      });
    } else {
      await userRef.update({'lastLogin': Timestamp.now()});
    }
  }

  /// Ambil role user berdasarkan uid
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['role'] != null) {
        debugPrint('🟢 User role = ${doc['role']}');
        return doc['role'] as String;
      }
    } catch (e) {
      debugPrint('🔴 Error getting user role: $e');
    }
    return 'user';
  }

  /// Update profil user
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
      debugPrint("✅ Profil berhasil diperbarui");
    } catch (e) {
      debugPrint("❌ Gagal memperbarui profil: $e");
      rethrow;
    }
  }
}
