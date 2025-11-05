import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> hasCompletedOnboarding();
  Future<void> setOnboardingCompleted();
  Future<void> resetOnboarding();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> hasCompletedOnboarding() async {
    return sharedPreferences.getBool(_keyOnboardingCompleted) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await sharedPreferences.setBool(_keyOnboardingCompleted, true);
  }

  @override
  Future<void> resetOnboarding() async {
    await sharedPreferences.remove(_keyOnboardingCompleted);
  }
}

