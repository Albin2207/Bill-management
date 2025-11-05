import 'package:flutter/foundation.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingProvider with ChangeNotifier {
  final OnboardingRepository repository;
  
  bool _hasCompletedOnboarding = false;
  bool _isLoading = false;
  
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;

  OnboardingProvider({required this.repository});

  /// Check if user has completed onboarding
  Future<void> checkOnboardingStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _hasCompletedOnboarding = await repository.hasCompletedOnboarding();
    } catch (e) {
      _hasCompletedOnboarding = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    try {
      await repository.setOnboardingCompleted();
      _hasCompletedOnboarding = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    try {
      await repository.resetOnboarding();
      _hasCompletedOnboarding = false;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to reset onboarding: $e');
    }
  }
}

