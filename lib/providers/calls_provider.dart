import 'package:flutter/foundation.dart';

class CallsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _calls = [];

  List<Map<String, dynamic>> get calls => _calls;

  void addCall(Map<String, dynamic> call) {
    _calls.insert(0, call);
    notifyListeners();
  }

  void updateCallStatus(String callId, String status) {
    final index = _calls.indexWhere((call) => call['id'] == callId);
    if (index != -1) {
      _calls[index]['executionStatus'] = status;
      _calls[index]['isCompleted'] = status == 'Завершён';
      notifyListeners();
    }
  }

  Map<String, dynamic>? getCallById(String id) {
    return _calls.firstWhere((call) => call['id'] == id, orElse: () => {});
  }
}
