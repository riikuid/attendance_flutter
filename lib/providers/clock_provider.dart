import 'dart:async';
import 'package:flutter/foundation.dart';

class ClockProvider with ChangeNotifier {
  late final Timer _timer;
  DateTime _nowWIB = DateTime.now().toUtc().add(const Duration(hours: 7));

  DateTime get nowWIB => _nowWIB;

  ClockProvider() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _nowWIB = DateTime.now().toUtc().add(const Duration(hours: 7));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
