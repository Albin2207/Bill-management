import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      return await localDataSource.hasCompletedOnboarding();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setOnboardingCompleted() async {
    try {
      await localDataSource.setOnboardingCompleted();
    } catch (e) {
      throw Exception('Failed to save onboarding state: $e');
    }
  }

  @override
  Future<void> resetOnboarding() async {
    try {
      await localDataSource.resetOnboarding();
    } catch (e) {
      throw Exception('Failed to reset onboarding: $e');
    }
  }
}

