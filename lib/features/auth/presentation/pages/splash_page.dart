import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../../../business/presentation/providers/business_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait minimum splash duration
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      
      // Step 1: Check if user has seen app onboarding
      await onboardingProvider.checkOnboardingStatus();
      
      if (!mounted) return;
      
      if (!onboardingProvider.hasCompletedOnboarding) {
        // First time user - show app onboarding
        Navigator.of(context).pushReplacementNamed(AppRouter.appOnboarding);
        return;
      }
      
      // Step 2: Check authentication status
      await authProvider.checkAuthStatus();
      
      if (!mounted) return;
      
      // Navigate based on auth status
      if (authProvider.isAuthenticated) {
        try {
          final currentUserId = authProvider.user!.uid;
          
          // Clear any old business data first
          businessProvider.clearBusiness();
          
          // Load business for current user
          await businessProvider.loadBusiness(currentUserId);
          
          if (!mounted) return;
          
          // Check if business exists, belongs to current user, AND is complete
          final hasValidBusiness = businessProvider.business != null &&
              businessProvider.business!.userId == currentUserId &&
              businessProvider.hasCompletedOnboarding;
          
          if (hasValidBusiness) {
            // Existing user with complete profile - go to home
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          } else {
            // New user OR incomplete profile - show business onboarding
            Navigator.of(context).pushReplacementNamed(AppRouter.businessOnboarding);
          }
        } catch (e) {
          debugPrint('Error loading business: $e');
          // On error, show business onboarding to let user set up
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppRouter.businessOnboarding);
        }
      } else {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in splash initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      // Navigate to login on error
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo placeholder - will be replaced with actual logo image
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: AppColors.onPrimary,
                        ),
                        // TODO: Replace with: Image.asset('assets/images/logo.png')
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // App Name with fade-in animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GST Management Made Easy',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.onPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Loading indicator with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: AppColors.onPrimary.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Version or tagline
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppColors.onPrimary.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

