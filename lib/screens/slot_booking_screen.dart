import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../app/routes.dart';
import '../models/booking.dart';
import '../models/farmer.dart';
import '../models/slot.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../services/mock_data_service.dart';
import '../utils/formatters.dart';
import '../widgets/info_card.dart';
import '../widgets/status_badge.dart';

class SlotBookingScreen extends StatefulWidget {
  const SlotBookingScreen({super.key});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  Future<void> _pickCustomDate(BuildContext context) async {
    final bookingProvider = context.read<BookingProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: bookingProvider.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      bookingProvider.setDate(picked);
    }
  }

  void _confirmBooking(MandiSlot slot) {
    final bookingProvider = context.read<BookingProvider>();
    final authProvider = context.read<AuthProvider>();
    final farmer = authProvider.displayFarmer;

    final newBooking = _tryCreateBooking(bookingProvider, slot, farmer);
    if (newBooking == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.of(context).slotFull)));
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.bookingConfirmation,
      arguments: newBooking,
    );
  }

  Booking? _tryCreateBooking(
    BookingProvider bookingProvider,
    MandiSlot slot,
    Farmer farmer,
  ) {
    try {
      return bookingProvider.bookSlot(slot: slot, farmer: farmer);
    } on StateError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final filteredSlots = bookingProvider.filteredSlots;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.bookProcurementSlot),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: bookingProvider.selectedMandi,
                            isDense: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primaryGreen,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            items: bookingProvider.availableMandis.map((mandi) {
                              return DropdownMenuItem(
                                value: mandi,
                                child: Text(mandi),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) bookingProvider.setMandi(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _DateFilterChip(
                          label: s.todayLabel,
                          date: MockDataService.today,
                          isSelected: _isSameDay(
                            bookingProvider.selectedDate,
                            MockDataService.today,
                          ),
                          onTap: () =>
                              bookingProvider.setDate(MockDataService.today),
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: s.tomorrow,
                          date: MockDataService.tomorrow,
                          isSelected: _isSameDay(
                            bookingProvider.selectedDate,
                            MockDataService.tomorrow,
                          ),
                          onTap: () =>
                              bookingProvider.setDate(MockDataService.tomorrow),
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: s.dayAfter,
                          date: MockDataService.dayAfter,
                          isSelected: _isSameDay(
                            bookingProvider.selectedDate,
                            MockDataService.dayAfter,
                          ),
                          onTap: () =>
                              bookingProvider.setDate(MockDataService.dayAfter),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.primaryGreen,
                          ),
                          label: Text(s.pickDate),
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                          backgroundColor: AppColors.surfacePaleGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: AppColors.borderSubtle,
                            ),
                          ),
                          onPressed: () => _pickCustomDate(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: bookingProvider.availableCrops.map((crop) {
                        final isSelected = bookingProvider.selectedCrop == crop;
                        final cropLabel = crop == 'all'
                            ? s.allCrops
                            : s.cropName(crop);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cropLabel),
                            selected: isSelected,
                            selectedColor: AppColors.primaryGreen,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) bookingProvider.setCrop(crop);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),

            Expanded(
              child: filteredSlots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.noSlotsAvailable,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.tryDifferentSelection,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      itemCount: filteredSlots.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final slot = filteredSlots[index];
                        final isAvailable = slot.status != SlotStatus.full;

                        return InfoCard(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingLarge,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_rounded,
                                          size: 16,
                                          color: AppColors.primaryGreen,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            slot.timeRange,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    label: slot.status == SlotStatus.available
                                        ? s.available
                                        : slot.status == SlotStatus.fillingFast
                                        ? s.fillingFast
                                        : s.slotFull,
                                    type: slot.status == SlotStatus.available
                                        ? BadgeType.success
                                        : slot.status == SlotStatus.fillingFast
                                        ? BadgeType.warning
                                        : BadgeType.danger,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfacePaleGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${slot.gate} • ${s.cropName(slot.crop)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${slot.bookedCount} / ${slot.totalCapacity} ${s.booked}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: slot.occupancyRate,
                                  minHeight: 6,
                                  backgroundColor: AppColors.borderSubtle,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    slot.status == SlotStatus.fillingFast
                                        ? AppColors.statusWarning
                                        : AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 44,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isAvailable
                                      ? () => _confirmBooking(slot)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    isAvailable ? s.bookSlotButton : s.slotFull,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateFilterChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateFilterChip({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('$label (${AppFormatters.formatShortDate(date)})'),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryGreen : AppColors.borderSubtle,
        ),
      ),
      onSelected: (_) => onTap(),
    );
  }
}
