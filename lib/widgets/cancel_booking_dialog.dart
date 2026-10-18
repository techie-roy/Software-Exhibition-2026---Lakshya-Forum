import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';

Future<Booking?> showCancelBookingDialog(
  BuildContext context,
  Booking booking,
) {
  return showDialog<Booking>(
    context: context,
    builder: (ctx) => CancelBookingDialog(booking: booking),
  );
}

class CancelBookingDialog extends StatefulWidget {
  final Booking booking;

  const CancelBookingDialog({super.key, required this.booking});

  @override
  State<CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<CancelBookingDialog> {
  bool _isCancelling = false;

  Future<void> _confirmCancel() async {
    setState(() => _isCancelling = true);
    final bookingProvider = context.read<BookingProvider>();
    final cancelled = bookingProvider.cancelBooking(widget.booking.id);
    if (!mounted) return;
    if (cancelled == null) {
      Navigator.of(context).pop(null);
      return;
    }
    setState(() => _isCancelling = false);
    Navigator.of(context).pop(cancelled);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      icon: Icon(
        Icons.event_busy_outlined,
        color: AppColors.statusAlert,
        size: 40,
      ),
      title: Text(
        s.cancelBookingAction,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.cancelBookingConfirm, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoftMint,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(s.tokenDetails, widget.booking.tokenNumber),
                const SizedBox(height: 6),
                _detailRow(s.crop, s.cropName(widget.booking.crop)),
                const SizedBox(height: 6),
                _detailRow(s.timeSlot, widget.booking.timeRange),
                const SizedBox(height: 6),
                _detailRow('Gate', widget.booking.gate),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Keep Booking mirrors the Cancel button's shape and sizing so the
        // pair is visually consistent, but in the app's green theme.
        ElevatedButton(
          onPressed: _isCancelling ? null : () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          child: Text(s.keepBooking),
        ),
        ElevatedButton(
          onPressed: _isCancelling ? null : _confirmCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusAlert,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          child: _isCancelling
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(s.confirmCancel),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
