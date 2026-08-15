import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/payment_model.dart';
import '../data/payments_repository.dart';

class PaymentsProvider extends ChangeNotifier {
  PaymentsProvider({PaymentsRepository? repository})
    : _repository = repository ?? PaymentsRepository();

  final PaymentsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<PaymentModel> _payments = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PaymentModel> get payments => List.unmodifiable(_payments);

  Future<PaymentModel?> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    String? cardholder,
  }) async {
    _begin();
    try {
      final payment = await _repository.createPayment(
        cardNumber: cardNumber,
        cvv: cvv,
        expMonth: expMonth,
        expYear: expYear,
        cardholder: cardholder,
      );
      _payments = [
        payment,
        ..._payments.where((item) => item.id != payment.id),
      ];
      return payment;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _finish();
    }
  }

  Future<void> loadPayments() async {
    _begin();
    try {
      _payments = await _repository.getMyPayments();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _finish();
    }
  }

  void _begin() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _finish() {
    _isLoading = false;
    notifyListeners();
  }
}
