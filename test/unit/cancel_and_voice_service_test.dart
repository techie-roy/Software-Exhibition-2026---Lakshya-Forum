import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/models/booking.dart';
import 'package:agri_queue/models/slot.dart';
import 'package:agri_queue/providers/booking_provider.dart';
import 'package:agri_queue/services/mock_data_service.dart';
import 'package:agri_queue/services/voice_booking_service.dart';

void main() {
  group('Cancel Booking', () {
    late MockDataService dataService;
    late BookingProvider bookingProvider;

    setUp(() {
      dataService = MockDataService();
      bookingProvider = BookingProvider(dataService);
    });

    test('Cancels an active booking and marks it cancelled', () {
      final active = dataService.activeBooking;
      final cancelled = dataService.cancelBooking(active.id);

      expect(cancelled, isNotNull);
      expect(cancelled!.status, equals(BookingStatus.cancelled));
      expect(dataService.activeBooking.status, equals(BookingStatus.cancelled));
    });

    test('Cancelling updates booking history list', () {
      final active = dataService.activeBooking;
      dataService.cancelBooking(active.id);

      final updated = dataService.allBookings.firstWhere(
        (b) => b.id == active.id,
      );
      expect(updated.status, equals(BookingStatus.cancelled));
    });

    test('Booking id preserved during cancellation', () {
      final active = dataService.activeBooking;
      final cancelled = dataService.cancelBooking(active.id);
      expect(cancelled!.id, equals(active.id));
      expect(cancelled.tokenNumber, equals(active.tokenNumber));
    });

    test('Unknown booking id returns null without side effects', () {
      final cancelled = dataService.cancelBooking('NONEXISTENT-ID');
      expect(cancelled, isNull);
      expect(dataService.activeBooking.status, equals(BookingStatus.inQueue));
    });

    test('Cannot cancel a completed booking', () {
      final completed = dataService.allBookings.firstWhere(
        (b) => b.status == BookingStatus.completed,
      );
      final cancelled = dataService.cancelBooking(completed.id);
      expect(cancelled, isNull);
    });

    test('Releases slot capacity so the slot becomes available again', () {
      final slotBefore = dataService.availableSlots.firstWhere(
        (s) =>
            s.crop == dataService.activeBooking.crop &&
            s.timeRange == dataService.activeBooking.timeRange,
      );

      final bookedCountBefore = slotBefore.bookedCount;
      final cancelled = dataService.cancelBooking(dataService.activeBooking.id);
      expect(cancelled, isNotNull);

      final slotAfter = dataService.availableSlots.firstWhere(
        (s) =>
            s.crop == dataService.activeBooking.crop &&
            s.timeRange == dataService.activeBooking.timeRange,
      );

      expect(slotAfter.bookedCount, equals(bookedCountBefore - 1));
      expect(slotAfter.status, equals(SlotStatus.available));
    });

    test('BookingProvider exposes cancelBooking and notifies listeners', () {
      final active = dataService.activeBooking;
      var notified = false;
      bookingProvider.addListener(() => notified = true);

      final cancelled = bookingProvider.cancelBooking(active.id);
      expect(cancelled, isNotNull);
      expect(notified, isTrue);
      expect(
        bookingProvider.activeBooking.status,
        equals(BookingStatus.cancelled),
      );
    });
  });

  group('VoiceBookingService crop recognition', () {
    test('Recognizes English crop names case-insensitively', () {
      expect(
        VoiceBookingService.recognizeCrop('I want wheat'),
        equals('wheat'),
      );
      expect(
        VoiceBookingService.recognizeCrop('book paddy slot'),
        equals('paddy'),
      );
      expect(
        VoiceBookingService.recognizeCrop('mustard please'),
        equals('mustard'),
      );
    });

    test('Recognizes Hindi crop names', () {
      expect(VoiceBookingService.recognizeCrop('गेहूं'), equals('wheat'));
      expect(
        VoiceBookingService.recognizeCrop('मुझे धान चाहिए'),
        equals('paddy'),
      );
      expect(VoiceBookingService.recognizeCrop('सरसों'), equals('mustard'));
      expect(VoiceBookingService.recognizeCrop('मक्का'), equals('maize'));
      expect(VoiceBookingService.recognizeCrop('गन्ना'), equals('sugarcane'));
      expect(VoiceBookingService.recognizeCrop('आलू'), equals('potato'));
    });

    test('Unknown text returns null', () {
      expect(VoiceBookingService.recognizeCrop('hello there'), isNull);
      expect(VoiceBookingService.recognizeCrop(''), isNull);
    });
  });

  group('VoiceBookingService time recognition', () {
    test('Recognizes plain numeric hours', () {
      expect(VoiceBookingService.recognizeHour('book at 9'), equals(9));
      expect(VoiceBookingService.recognizeHour('I need 11 slot'), equals(11));
    });

    test('Recognizes 12-hour clock with meridiem', () {
      expect(VoiceBookingService.recognizeHour('9 am'), equals(9));
      expect(VoiceBookingService.recognizeHour('9 pm'), equals(21));
      expect(VoiceBookingService.recognizeHour('12 pm'), equals(12));
      expect(VoiceBookingService.recognizeHour('12 am'), equals(0));
    });

    test('Recognizes English hour words', () {
      expect(VoiceBookingService.recognizeHour('three pm'), equals(15));
      expect(VoiceBookingService.recognizeHour('ten in morning'), equals(10));
    });

    test('Recognizes Hindi hour words', () {
      expect(VoiceBookingService.recognizeHour('नौ बजे'), equals(9));
      expect(VoiceBookingService.recognizeHour('सुबह नौ'), equals(9));
      expect(VoiceBookingService.recognizeHour('दस बजे'), equals(10));
    });
  });

  group('VoiceBookingService best slot matching', () {
    late List<MandiSlot> slots;

    setUp(() {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      slots = [
        MandiSlot(
          id: 'S1',
          mandiId: 'M',
          mandiName: 'Lucknow Central Mandi',
          date: today,
          timeRange: '07:00 AM – 09:00 AM',
          crop: 'wheat',
          gate: 'Gate 2',
          totalCapacity: 600,
          bookedCount: 350,
          status: SlotStatus.available,
        ),
        MandiSlot(
          id: 'S2',
          mandiId: 'M',
          mandiName: 'Lucknow Central Mandi',
          date: today,
          timeRange: '09:00 AM – 11:00 AM',
          crop: 'wheat',
          gate: 'Gate 2',
          totalCapacity: 600,
          bookedCount: 540,
          status: SlotStatus.fillingFast,
        ),
        MandiSlot(
          id: 'S3',
          mandiId: 'M',
          mandiName: 'Lucknow Central Mandi',
          date: today,
          timeRange: '11:00 AM – 01:00 PM',
          crop: 'wheat',
          gate: 'Gate 2',
          totalCapacity: 600,
          bookedCount: 600,
          status: SlotStatus.full,
        ),
        MandiSlot(
          id: 'S4',
          mandiId: 'M',
          mandiName: 'Lucknow Central Mandi',
          date: tomorrow,
          timeRange: '09:00 AM – 11:00 AM',
          crop: 'wheat',
          gate: 'Gate 2',
          totalCapacity: 600,
          bookedCount: 120,
          status: SlotStatus.available,
        ),
        MandiSlot(
          id: 'S5',
          mandiId: 'M',
          mandiName: 'Lucknow Central Mandi',
          date: today,
          timeRange: '11:00 AM – 01:00 PM',
          crop: 'paddy',
          gate: 'Gate 4',
          totalCapacity: 600,
          bookedCount: 200,
          status: SlotStatus.available,
        ),
      ];
    });

    test('Prefers exact-time slot on same day', () {
      final matches = VoiceBookingService.findBestSlots(
        slots: slots,
        cropId: 'wheat',
        targetHour: 9,
      );
      expect(matches.first.slot.id, equals('S2'));
      expect(matches.first.hourDifference, equals(0));
    });

    test('If exact slot is full, picks closest available', () {
      final matches = VoiceBookingService.findBestSlots(
        slots: slots,
        cropId: 'wheat',
        targetHour: 11,
      );
      expect(matches.any((m) => m.slot.id == 'S3'), isFalse);
      expect(matches.first.slot.id, equals('S2'));
    });

    test('Filters slots to requested crop only', () {
      final matches = VoiceBookingService.findBestSlots(
        slots: slots,
        cropId: 'paddy',
        targetHour: 9,
      );
      expect(matches.every((m) => m.slot.crop == 'paddy'), isTrue);
    });

    test('Empty result when no matching crop slots', () {
      final matches = VoiceBookingService.findBestSlots(
        slots: slots,
        cropId: 'maize',
        targetHour: 9,
      );
      expect(matches, isEmpty);
    });
  });
}
