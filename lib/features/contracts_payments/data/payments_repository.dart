import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/payment_model.dart';

class PaymentsRepository {
  PaymentsRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<PaymentModel> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    String? cardholder,
  }) async {
    try {
      final response = await _dio.post(
        '/payments',
        data: {
          'cardNumber': cardNumber,
          'cvv': cvv,
          'expMonth': expMonth,
          'expYear': expYear,
          if (cardholder != null && cardholder.trim().isNotEmpty)
            'cardholder': cardholder.trim(),
        },
      );
      return PaymentModel.fromJson(_asMap(_data(response.data)));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final response = await _dio.get('/me/payments');
      final data = _data(response.data);
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((item) => PaymentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static dynamic _data(dynamic response) {
    if (response is Map && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }
}
