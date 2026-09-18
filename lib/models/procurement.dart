enum PaymentStatus { paid, processing, pending }

class ProcurementTransaction {
  final String id;
  final String crop;
  final double quantityQuintals;
  final double ratePerQuintal;
  final double totalAmount;
  final DateTime date;
  final String transactionId;
  final PaymentStatus status;
  final String mandiName;
  final String bankAccountMasked;
  final String utrNumber;

  const ProcurementTransaction({
    required this.id,
    required this.crop,
    required this.quantityQuintals,
    required this.ratePerQuintal,
    required this.totalAmount,
    required this.date,
    required this.transactionId,
    required this.status,
    required this.mandiName,
    required this.bankAccountMasked,
    required this.utrNumber,
  });
}

class ProcurementOverview {
  final double totalEarnings;
  final double paidAmount;
  final double processingAmount;
  final double pendingAmount;

  const ProcurementOverview({
    required this.totalEarnings,
    required this.paidAmount,
    required this.processingAmount,
    required this.pendingAmount,
  });
}
