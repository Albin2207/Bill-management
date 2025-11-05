/// Repository interface for onboarding state management
abstract class OnboardingRepository {
  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding();
  
  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted();
  
  /// Reset onboarding (for testing)
  Future<void> resetOnboarding();
}

