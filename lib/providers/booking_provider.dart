import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/farmer.dart';
import '../models/slot.dart';
import '../services/mock_data_service.dart';

class BookingProvider extends ChangeNotifier {
  final MockDataService _dataService;

  DateTime _selectedDate = MockDataService.today;
  String _selectedCrop = 'all';
  String _selectedMandi = 'Lucknow Central Mandi';

  BookingProvider(this._dataService);

  DateTime get selectedDate => _selectedDate;
  String get selectedCrop => _selectedCrop;
  String get selectedMandi => _selectedMandi;

  Booking get activeBooking => _dataService.activeBooking;
  List<Booking> get allBookings => _dataService.allBookings;
  List<MandiGateStatus> get gateStatuses => _dataService.gateStatuses;
  List<MandiSlot> get availableSlots => _dataService.availableSlots;

  List<String> get availableCrops => [
    'all',
    'wheat',
    'paddy',
    'mustard',
    'maize',
    'sugarcane',
  ];

  List<String> get availableMandis => [
    'Lucknow Central Mandi',
    'Sitapur Road Mandi',
    'Barabanki Mandi',
  ];

  List<MandiSlot> get filteredSlots {
    return _dataService.availableSlots.where((slot) {
      final matchesDate =
          slot.date.year == _selectedDate.year &&
          slot.date.month == _selectedDate.month &&
          slot.date.day == _selectedDate.day;

      final matchesCrop = _selectedCrop == 'all' || slot.crop == _selectedCrop;

      final matchesMandi = slot.mandiName == _selectedMandi;

      return matchesDate && matchesCrop && matchesMandi;
    }).toList();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  void setMandi(String mandi) {
    _selectedMandi = mandi;
    notifyListeners();
  }

  Booking bookSlot({required MandiSlot slot, required Farmer farmer}) {
    final booking = _dataService.bookSlot(
      slot: slot,
      farmerId: farmer.id,
      farmerName: farmer.name,
    );
    notifyListeners();
    return booking;
  }

  Booking? cancelBooking(String bookingId) {
    final cancelled = _dataService.cancelBooking(bookingId);
    if (cancelled != null) {
      notifyListeners();
    }
    return cancelled;
  }
}
