import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class AttendanceProvider with ChangeNotifier {
  final FirestoreService service;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  AttendanceProvider(this.service);

  Future<void> checkIn(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await service.checkIn(uid: uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkOut(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await service.checkOut(uid: uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
