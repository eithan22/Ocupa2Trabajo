import 'package:flutter/material.dart';
import '../../../models/job_type_model.dart';
import '../../../models/offer_model.dart';
import '../data/offers_repository.dart';

class OffersProvider extends ChangeNotifier {
  final OffersRepository _repository = OffersRepository();


  bool _isLoading = false;
  String? _errorMessage;

  List<JobTypeModel> _jobTypes = [];
  List<OfferModel> _offers = [];
  List<OfferModel> _myOffers = [];
  OfferModel? _currentOffer;


  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<JobTypeModel> get jobTypes => _jobTypes;
  List<OfferModel> get offers => _offers;
  List<OfferModel> get myOffers => _myOffers;
  OfferModel? get currentOffer => _currentOffer;


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }



  Future<void> fetchJobTypes() async {
    _setLoading(true);
    _setError(null);
    try {
      _jobTypes = await _repository.getJobTypes();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOffers({String? jobTypeKey, String? contractType}) async {
    _setLoading(true);
    _setError(null);
    try {
      _offers = await _repository.getOffers(
        jobTypeKey: jobTypeKey,
        contractType: contractType,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyOffers() async {
    _setLoading(true);
    _setError(null);
    try {
      _myOffers = await _repository.getMyOffers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOfferDetail(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentOffer = await _repository.getOfferDetail(id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> publishOffer(Map<String, dynamic> offerData) async {
    _setLoading(true);
    _setError(null);
    try {
      final newOffer = await _repository.createOffer(offerData);
      _myOffers.insert(0, newOffer);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deactivateOffer(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.deactivateOffer(id);

      _myOffers.removeWhere((offer) => offer.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}