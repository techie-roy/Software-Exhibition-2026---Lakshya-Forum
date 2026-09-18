import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../models/booking.dart';
import '../models/procurement.dart';
import '../providers/booking_provider.dart';
import '../services/mock_data_service.dart';
import '../utils/formatters.dart';
import '../widgets/cancel_booking_dialog.dart';
import '../widgets/info_card.dart';
import '../widgets/status_badge.dart';

class ProcurementScreen extends StatefulWidget {
  const ProcurementScreen({super.key});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockDataService _dataService = MockDataService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSlipDialog(ProcurementTransaction txn) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            Text(
              s.eProcurementSlip,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SlipRow(label: s.transactionId, value: txn.transactionId),
              const Divider(height: 16),
              _SlipRow(label: s.cropProcured, value: s.cropName(txn.crop)),
              const Divider(height: 16),
              _SlipRow(
                label: s.quantity,
                value: '${txn.quantityQuintals} ${s.quintals}',
              ),
              const Divider(height: 16),
              _SlipRow(
                label: s.ratePerQuintal,
                value: AppFormatters.formatCurrency(txn.ratePerQuintal),
              ),
              const Divider(height: 16),
              _SlipRow(
                label: s.totalNetAmount,
                value: AppFormatters.formatCurrency(txn.totalAmount),
                isBold: true,
              ),
              const Divider(height: 16),
              _SlipRow(label: s.bankAccount, value: txn.bankAccountMasked),
              const Divider(height: 16),
              _SlipRow(label: s.utrReference, value: txn.utrNumber),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              s.close,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(s.slipDownloaded),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(s.downloadPdf),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overview = _dataService.procurementOverview;
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.allBookings;
    final transactions = _dataService.transactions;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.myBookingsPayments),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: s.paymentHistory),
            Tab(text: s.mandiBookings),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoCard(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.totalEarnings,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(overview.totalEarnings),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.borderSubtle),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricPill(
                                label: s.paid,
                                amount: AppFormatters.formatCurrency(
                                  overview.paidAmount,
                                ),
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricPill(
                                label: s.processingLabel,
                                amount: AppFormatters.formatCurrency(
                                  overview.processingAmount,
                                ),
                                color: AppColors.statusWarning,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricPill(
                                label: s.pendingLabel,
                                amount: AppFormatters.formatCurrency(
                                  overview.pendingAmount,
                                ),
                                color: AppColors.statusPending,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Text(
                      s.procurementTransactions,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...transactions.map((txn) {
                    final isPaid = txn.status == PaymentStatus.paid;
                    final isProcessing = txn.status == PaymentStatus.processing;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InfoCard(
                        onTap: () => _showSlipDialog(txn),
                        padding: const EdgeInsets.all(
                          AppDimensions.paddingMedium,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.cropName(txn.crop),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${txn.quantityQuintals} ${s.qtl} • ${txn.transactionId}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      AppFormatters.formatCurrency(
                                        txn.totalAmount,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge(
                                      label: isPaid
                                          ? s.paid
                                          : isProcessing
                                          ? s.processingLabel
                                          : s.pendingLabel,
                                      type: isPaid
                                          ? BadgeType.success
                                          : isProcessing
                                          ? BadgeType.warning
                                          : BadgeType.info,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppFormatters.formatDate(txn.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      s.viewSlip,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final isConfirmed =
                    booking.status == BookingStatus.confirmed ||
                    booking.status == BookingStatus.inQueue;

                return InfoCard(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              booking.tokenNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          StatusBadge(
                            label: booking.status == BookingStatus.confirmed
                                ? s.confirmed
                                : booking.status == BookingStatus.inQueue
                                ? s.inQueue
                                : booking.status == BookingStatus.completed
                                ? s.completed
                                : s.cancelled,
                            type: isConfirmed
                                ? BadgeType.success
                                : BadgeType.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${s.cropName(booking.crop)} • ${booking.gate}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppFormatters.formatDate(booking.date)} | ${booking.timeRange}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${s.bookingId}${booking.id}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (isConfirmed) ...[
                        const SizedBox(height: 10),
                        const Divider(
                          height: 1,
                          color: AppColors.borderSubtle,
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final cancelled = await showCancelBookingDialog(
                              context,
                              booking,
                            );
                            if (cancelled != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(s.bookingCancelledSuccess),
                                  backgroundColor: AppColors.statusAlert,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_busy_outlined,
                                  size: 16,
                                  color: AppColors.statusAlert,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s.cancelBookingAction,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.statusAlert,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SlipRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SlipRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primaryGreen : AppColors.textPrimary,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
