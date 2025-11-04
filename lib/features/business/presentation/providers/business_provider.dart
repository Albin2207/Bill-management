import 'package:flutter/foundation.dart';
import '../../domain/entities/business_entity.dart';
import '../../domain/usecases/get_business_usecase.dart';
import '../../domain/usecases/save_business_usecase.dart';
import '../../domain/usecases/update_business_usecase.dart';

class BusinessProvider extends ChangeNotifier {
  final GetBusinessUsecase getBusinessUsecase;
  final SaveBusinessUsecase saveBusinessUsecase;
  final UpdateBusinessUsecase updateBusinessUsecase;

  BusinessProvider({
    required this.getBusinessUsecase,
    required this.saveBusinessUsecase,
    required this.updateBusinessUsecase,
  });

  BusinessEntity? _business;
  BusinessEntity? get business => _business;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasCompletedOnboarding => _business?.isOnboardingComplete ?? false;

  // Load business profile
  Future<void> loadBusiness(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _business = await getBusinessUsecase(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save new business (during onboarding)
  Future<bool> saveBusiness(BusinessEntity business) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await saveBusinessUsecase(business);
      _business = business;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update existing business
  Future<bool> updateBusiness(BusinessEntity business) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await updateBusinessUsecase(business);
      _business = business;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update logo URL
  Future<bool> updateLogo(String logoUrl) async {
    if (_business == null) return false;

    final updated = _business!.copyWith(
      logoUrl: logoUrl,
      updatedAt: DateTime.now(),
    );

    return await updateBusiness(updated);
  }

  // Update signature URL
  Future<bool> updateSignature(String signatureUrl) async {
    if (_business == null) return false;

    final updated = _business!.copyWith(
      signatureUrl: signatureUrl,
      updatedAt: DateTime.now(),
    );

    return await updateBusiness(updated);
  }

  // Mark onboarding as complete
  Future<bool> completeOnboarding() async {
    if (_business == null) return false;

    final updated = _business!.copyWith(
      isOnboardingComplete: true,
      updatedAt: DateTime.now(),
    );

    return await updateBusiness(updated);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data (on logout)
  void clearBusiness() {
    _business = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}

