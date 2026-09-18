import 'package:flutter/foundation.dart';

import '../models/queue.dart';
import '../services/mock_data_service.dart';

class QueueProvider extends ChangeNotifier {
  final MockDataService _dataService;

  late LiveQueueData _queueData;
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime _lastUpdated = DateTime.now();
  int _refreshCount = 0;

  QueueProvider(this._dataService) {
    _queueData = _dataService.getLiveQueueData();
  }

  LiveQueueData get queueData => _queueData;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  DateTime get lastUpdated => _lastUpdated;
  int get refreshCount => _refreshCount;

  Future<void> refreshQueue() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network latency so the teacher can see the loading state.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _queueData = _dataService.getLiveQueueData();
      _lastUpdated = DateTime.now();
      _refreshCount++;
    } catch (_) {
      // Retain the last successful queue data on failure.
      _errorMessage = 'queue_refresh_error';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
