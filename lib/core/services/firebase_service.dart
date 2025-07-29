import 'package:palm_diagnose/global.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data();
  }

  static User? get currentUser => FirebaseAuth.instance.currentUser;
  // Ambil semua user sebagai Stream
  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          // ignore: unnecessary_null_comparison
          .where((doc) => doc.data() != null)
          .map((doc) => doc.data())
          .toList();
    });
  }

  /// ✅ Simpan data user ke Firestore (jika belum ada)
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
        ...?additionalData, // ← tambahan jika ada username, phone, dsb.
      });
    } else {
      await userRef.update({'lastLogin': Timestamp.now()});
    }
  }

  /// 👑 Ambil role user dari Firestore
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
    return 'user'; // fallback
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
      debugPrint("✅ Profil berhasil diperbarui");
    } catch (e) {
      debugPrint("❌ Gagal memperbarui profil: $e");
      rethrow;
    }
  }

  /// 💾 Simpan hasil deteksi penyakit daun kelapa
  Future<void> saveDetectionResults({
    required String uid,
    required String filename,
    required List<Map<String, dynamic>>
    results, // isinya model, label, confidence
  }) async {
    await _db.collection('detections').add({
      'uid': uid,
      'filename': filename,
      'results': results,
      'timestamp': Timestamp.now(),
    });
  }

  /// 📥 Ambil data deteksi milik user tertentu
  Stream<QuerySnapshot> getUserDetections(String uid) {
    return _db
        .collection('detections')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// 🛡️ Ambil semua data deteksi (untuk admin)
  Stream<QuerySnapshot> getAllDetections() {
    return _db
        .collection('detections')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
