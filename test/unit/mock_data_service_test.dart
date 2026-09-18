import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/models/slot.dart';
import 'package:agri_queue/services/mock_data_service.dart';

void main() {
  group('MockDataService Tests', () {
    late MockDataService dataService;

    setUp(() {
      dataService = MockDataService();
    });

    test('Initializes active booking for token A-125', () {
      final active = dataService.activeBooking;
      expect(active.tokenNumber, equals('A-125'));
      expect(active.gate, equals('Gate 2'));
      expect(active.crop, equals('wheat'));
      expect(active.farmerName, equals('Rajesh Kumar'));
    });

    test('Provides valid slots with capacity and availability', () {
      final slots = dataService.availableSlots;
      expect(slots.isNotEmpty, isTrue);

      final firstSlot = slots.first;
      expect(firstSlot.totalCapacity, greaterThan(0));
      expect(firstSlot.availableCapacity, greaterThanOrEqualTo(0));
      expect(firstSlot.status, equals(SlotStatus.available));
    });

    test('Books slot and updates active booking with new token', () {
      final targetSlot = dataService.availableSlots.last;
      final newBooking = dataService.bookSlot(
        slot: targetSlot,
        farmerId: 'FID-TEST-01',
        farmerName: 'Test Farmer',
      );

      expect(newBooking.id.startsWith('AQ-2026-'), isTrue);
      expect(dataService.activeBooking.id, equals(newBooking.id));
      expect(dataService.allBookings.first.id, equals(newBooking.id));
    });

    test('Retrieves live queue telemetry with 6 stages', () {
      final queueData = dataService.getLiveQueueData();
      expect(queueData.tokenNumber, equals('A-125'));
      expect(queueData.steps.length, equals(6));
      expect(queueData.steps[2].titleKey, equals('step_in_queue'));
      expect(queueData.steps[2].isCurrent, isTrue);
    });

    test('Live queue telemetry updates on each refresh', () {
      final first = dataService.getLiveQueueData();
      final second = dataService.getLiveQueueData();
      expect(first.farmersAhead, isNot(equals(second.farmersAhead)));
      expect(second.estimatedWaitMinutes, lessThan(first.estimatedWaitMinutes));
    });

    test('Crops are stored as stable IDs, not translated strings', () {
      final crops = dataService.availableSlots.map((s) => s.crop).toSet();
      expect(crops, isNot(contains('Wheat')));
      expect(crops, contains('wheat'));
      expect(crops, contains('paddy'));
      expect(crops, contains('mustard'));

      final gateCrops = dataService.gateStatuses.map((g) => g.crop).toSet();
      expect(gateCrops, isNot(contains('Wheat')));

      final priceIds = dataService.marketPrices.map((p) => p.cropName).toSet();
      expect(priceIds, contains('wheat'));
      expect(priceIds, isNot(contains('Wheat')));
    });

    test('Market prices contains required 6 crops', () {
      final prices = dataService.marketPrices;
      final cropNames = prices.map((p) => p.cropName.toLowerCase()).toList();

      expect(cropNames.any((name) => name.contains('wheat')), isTrue);
      expect(cropNames.any((name) => name.contains('paddy')), isTrue);
      expect(cropNames.any((name) => name.contains('maize')), isTrue);
      expect(cropNames.any((name) => name.contains('mustard')), isTrue);
      expect(cropNames.any((name) => name.contains('potato')), isTrue);
      expect(cropNames.any((name) => name.contains('sugarcane')), isTrue);
    });
  });
}
