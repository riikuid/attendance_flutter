import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final DateTime checkInAt;
  final DateTime? checkOutAt;

  const Attendance({
    required this.id,
    required this.checkInAt,
    this.checkOutAt,
  });

  factory Attendance.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Attendance(
      id: doc.id,
      checkInAt: (data['checkInAt'] as Timestamp).toDate(),
      checkOutAt: (data['checkOutAt'] as Timestamp?)?.toDate(),
    );
  }
}
