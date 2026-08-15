class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.cardLast4,
    this.createdAt,
  });

  final String id;
  final double amount;
  final String currency;
  final String status;
  final String? cardLast4;
  final DateTime? createdAt;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final cardNumber = json['cardNumber']?.toString();
    final last4 =
        json['cardLast4']?.toString() ??
        (cardNumber != null && cardNumber.length >= 4
            ? cardNumber.substring(cardNumber.length - 4)
            : null);

    return PaymentModel(
      id: (json['id'] ?? json['paymentId'] ?? '').toString(),
      amount: _toDouble(json['amount'] ?? json['value']) ?? 1,
      currency: (json['currency'] ?? 'USD').toString(),
      status:
          (json['status'] ??
                  (json['approved'] == true ? 'approved' : 'pending'))
              .toString(),
      cardLast4: last4,
      createdAt: _toDate(json['createdAt'] ?? json['date']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _toDate(dynamic value) {
    return value == null ? null : DateTime.tryParse(value.toString());
  }
}
