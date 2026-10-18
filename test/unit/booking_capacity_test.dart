import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/models/slot.dart';
import 'package:agri_queue/providers/booking_provider.dart';
import 'package:agri_queue/services/mock_data_service.dart';
import 'package:agri_queue/services/voice_booking_service.dart';

MandiSlot _slotById(MockDataService ds, String id) =>
    ds.availableSlots.firstWhere((s) => s.id == id);

void main() {
  group('Duplicate bookings (structural)', () {
    test('Initial allBookings has no duplicate ids', () {
      final ds = MockDataService();
      final ids = ds.allBookings.map((b) => b.id).toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('A new booking appears exactly once in allBookings', () {
      final ds = MockDataService();
      final booked = ds.bookSlot(
        slot: _slotById(ds, 'SLOT-201'),
        farmerId: 'FID-UP-78219',
        farmerName: 'Rajesh Kumar',
      );

      final ids = ds.allBookings.map((b) => b.id).toList();
      expect(
        ids.toSet().length,
        equals(ids.length),
        reason: 'no booking id may be listed twice',
      );
      expect(ids.where((id) => id == booked.id).length, equals(1));
      expect(ds.allBookings.first.id, equals(booked.id));
    });

    test(
      'Booking the same slot twice yields two distinct, non-duplicated ids',
      () {
        final ds = MockDataService();
        final first = ds.bookSlot(
          slot: _slotById(ds, 'SLOT-201'),
          farmerId: 'FID-UP-78219',
          farmerName: 'Rajesh Kumar',
        );
        final second = ds.bookSlot(
          slot: _slotById(ds, 'SLOT-201'),
          farmerId: 'FID-UP-78219',
          farmerName: 'Rajesh Kumar',
        );

        expect(first.id, isNot(equals(second.id)));
        final ids = ds.allBookings.map((b) => b.id).toList();
        expect(ids.toSet().length, equals(ids.length));
        expect(ids.where((id) => id == first.id).length, equals(1));
        expect(ids.where((id) => id == second.id).length, equals(1));
      },
    );
  });

  group('Slot capacity', () {
    test('Booking increments the slot bookedCount by exactly one', () {
      final ds = MockDataService();
      final before = _slotById(ds, 'SLOT-201').bookedCount;

      ds.bookSlot(
        slot: _slotById(ds, 'SLOT-201'),
        farmerId: 'F1',
        farmerName: 'Farmer One',
      );

      expect(_slotById(ds, 'SLOT-201').bookedCount, equals(before + 1));
    });

    test(
      'Booking a slot at capacity is rejected and does not exceed capacity',
      () {
        final ds = MockDataService();
        final fullSlot = MandiSlot(
          id: 'SLOT-FULL',
          mandiId: 'MND-LKO-01',
          mandiName: 'Lucknow Central Mandi',
          date: MockDataService.today,
          timeRange: '07:00 AM – 09:00 AM',
          crop: 'wheat',
          gate: 'Gate 2',
          totalCapacity: 10,
          bookedCount: 10,
          status: SlotStatus.full,
        );

        expect(
          () => ds.bookSlot(
            slot: fullSlot,
            farmerId: 'F1',
            farmerName: 'Farmer One',
          ),
          throwsStateError,
        );
      },
    );

    test(
      'Filling the last seats marks the slot full and then blocks booking',
      () {
        final ds = MockDataService();
        // SLOT-102 starts at 540 of 600 -> 60 seats remain.
        var slot = _slotById(ds, 'SLOT-102');
        final remaining = slot.availableCapacity;

        for (var i = 0; i < remaining; i++) {
          ds.bookSlot(
            slot: _slotById(ds, 'SLOT-102'),
            farmerId: 'F$i',
            farmerName: 'Farmer $i',
          );
        }

        slot = _slotById(ds, 'SLOT-102');
        expect(slot.bookedCount, equals(slot.totalCapacity));
        expect(slot.availableCapacity, equals(0));
        expect(slot.status, equals(SlotStatus.full));

        expect(
          () => ds.bookSlot(
            slot: _slotById(ds, 'SLOT-102'),
            farmerId: 'F-overflow',
            farmerName: 'Overflow Farmer',
          ),
          throwsStateError,
        );
        expect(
          _slotById(ds, 'SLOT-102').bookedCount,
          equals(slot.totalCapacity),
          reason: 'rejected booking must not exceed capacity',
        );
      },
    );
  });

  group('Cancellation symmetry', () {
    test('Book then cancel restores the slot to its original bookedCount', () {
      final ds = MockDataService();
      final before = _slotById(ds, 'SLOT-201');

      final booking = ds.bookSlot(
        slot: _slotById(ds, 'SLOT-201'),
        farmerId: 'FID-UP-78219',
        farmerName: 'Rajesh Kumar',
      );
      expect(
        _slotById(ds, 'SLOT-201').bookedCount,
        equals(before.bookedCount + 1),
      );

      final cancelled = ds.cancelBooking(booking.id);
      expect(cancelled, isNotNull);

      final after = _slotById(ds, 'SLOT-201');
      expect(after.bookedCount, equals(before.bookedCount));
      expect(after.status, equals(before.status));
    });

    test('Repeated cancellation releases capacity exactly once', () {
      final ds = MockDataService();
      final booking = ds.bookSlot(
        slot: _slotById(ds, 'SLOT-201'),
        farmerId: 'FID-UP-78219',
        farmerName: 'Rajesh Kumar',
      );

      final first = ds.cancelBooking(booking.id);
      expect(first, isNotNull);
      final afterFirst = _slotById(ds, 'SLOT-201').bookedCount;

      final second = ds.cancelBooking(booking.id);
      expect(
        second,
        isNull,
        reason: 'an already cancelled booking cannot cancel again',
      );
      expect(_slotById(ds, 'SLOT-201').bookedCount, equals(afterFirst));
    });

    test(
      'Cancellation never drives capacity below zero or above its maximum',
      () {
        final ds = MockDataService();
        // Cancel the seed active booking (SLOT-101 starts at 350/600).
        final original = _slotById(ds, 'SLOT-101').bookedCount;

        ds.cancelBooking(ds.activeBooking.id);
        final afterFirst = _slotById(ds, 'SLOT-101');

        expect(afterFirst.bookedCount, greaterThanOrEqualTo(0));
        expect(
          afterFirst.bookedCount,
          lessThanOrEqualTo(afterFirst.totalCapacity),
        );
        expect(afterFirst.bookedCount, equals(original - 1));

        // A repeated cancellation must not decrement again.
        ds.cancelBooking(ds.activeBooking.id);
        expect(_slotById(ds, 'SLOT-101').bookedCount, equals(original - 1));
      },
    );
  });

  group('Same-day bookings (existing rule: allowed)', () {
    test('A second same-day booking is permitted and recorded once', () {
      final ds = MockDataService();
      // Seed active booking is today, wheat, 07:00-09:00 (SLOT-101).
      final seed = ds.activeBooking;
      expect(seed.crop, equals('wheat'));

      // Book another wheat slot on the SAME day (SLOT-103, 11:00-13:00).
      final second = ds.bookSlot(
        slot: _slotById(ds, 'SLOT-103'),
        farmerId: seed.farmerId,
        farmerName: seed.farmerName,
      );

      expect(second.date.year, equals(seed.date.year));
      expect(second.date.month, equals(seed.date.month));
      expect(second.date.day, equals(seed.date.day));
      expect(ds.activeBooking.id, equals(second.id));

      final ids = ds.allBookings.map((b) => b.id).toList();
      expect(ids.toSet().length, equals(ids.length));
      expect(ids.contains(seed.id), isTrue);
      expect(ids.where((id) => id == second.id).length, equals(1));
    });
  });

  group('Voice booking slot discovery', () {
    test('Finds eligible slots independently of unrelated UI filters', () {
      final ds = MockDataService();
      final provider = BookingProvider(ds);

      // Apply UI filters that would exclude a wheat/today slot entirely.
      provider.setCrop('paddy');
      provider.setDate(MockDataService.tomorrow);
      provider.setMandi('Barabanki Mandi');
      expect(provider.filteredSlots, isEmpty);

      // Voice discovery searches the full inventory, so it still succeeds.
      final matches = VoiceBookingService.findBestSlots(
        slots: provider.availableSlots,
        cropId: 'wheat',
        targetHour: 9,
      );

      expect(matches, isNotEmpty);
      expect(matches.every((m) => m.slot.crop == 'wheat'), isTrue);
      expect(matches.first.hourDifference, equals(0));
      expect(matches.first.slot.id, equals('SLOT-102'));
    });
  });
}
