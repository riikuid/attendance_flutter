import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('attendance');

  // Stream dok terbaru (untuk deteksi shift aktif)
  Stream<Attendance?> streamLatestCheck(String uid) {
    return _col(uid)
        .orderBy('checkInAt', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (query) =>
              query.docs.isEmpty ? null : Attendance.fromDoc(query.docs.first),
        );
  }

  Stream<List<Attendance>> streamHistory(String uid) {
    return _col(uid)
        .orderBy('checkInAt', descending: true)
        .snapshots()
        .map((query) => query.docs.map(Attendance.fromDoc).toList());
  }

  Future<void> checkIn({required String uid}) async {
    await _col(uid).add({'checkInAt': FieldValue.serverTimestamp()});
  }

  Future<void> checkOut({required String uid}) async {
    final querySnapshot =
        await _col(uid).orderBy('checkInAt', descending: true).limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Belum ada kehadiran untuk di-check-out.');
    }

    final data = querySnapshot.docs.first.data();
    final isActive =
        !data.containsKey('checkOutAt') || data['checkOutAt'] == null;
    if (!isActive) {
      throw Exception('Tidak ada kehadiran yang aktif.');
    }

    await querySnapshot.docs.first.reference.update({
      'checkOutAt': FieldValue.serverTimestamp(),
    });
  }
}
