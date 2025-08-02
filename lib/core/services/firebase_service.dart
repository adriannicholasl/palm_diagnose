import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Simpan hasil deteksi
  Future<void> saveDetectionResults({
    required String uid,
    required String filename,
    required List<Map<String, dynamic>> results,
    Map<String, dynamic>? location, // Tambahkan
  }) async {
    await FirebaseFirestore.instance.collection('detections').add({
      'uid': uid,
      'filename': filename,
      'results': results,
      'timestamp': FieldValue.serverTimestamp(),
      if (location != null) 'location': location,
    });
  }

  /// Ambil deteksi berdasarkan user
  Stream<QuerySnapshot> getUserDetections(String uid) {
    return _db
        .collection('detections')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Hitung jumlah deteksi oleh user
  Future<int> getDetectionCountByUser(String uid) async {
    final snapshot = await _db
        .collection('detections')
        .where('uid', isEqualTo: uid)
        .get();
    return snapshot.docs.length;
  }

  /// Ambil semua deteksi (untuk admin)
  Stream<QuerySnapshot> getAllDetections() {
    return _db
        .collection('detections')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Hitung total deteksi semua user
  Future<Map<String, int>> getAllDetectionCountsGroupedByUser() async {
    final snapshot = await _db.collection('detections').get();
    final Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final uid = doc['uid'];
      if (uid != null) {
        counts[uid] = (counts[uid] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<Map<String, dynamic>?> getDiseaseInfo(String label) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('disease_info')
        .doc(label)
        .get();
    return snapshot.data();
  }
}
