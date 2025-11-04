import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../../../business/presentation/providers/business_provider.dart';

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
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      
      // Wait for auth check to complete
      await authProvider.checkAuthStatus();
      
      if (!mounted) return;
      
      // Navigate based on auth status
      if (authProvider.isAuthenticated) {
        // FORCE reload business for current user (clears old cache)
        await businessProvider.loadBusiness(authProvider.user!.uid);
        
        if (!mounted) return;
        
        // Check business belongs to current user AND is complete
        final currentUserId = authProvider.user!.uid;
        final hasValidBusiness = businessProvider.business != null &&
            businessProvider.business!.userId == currentUserId &&
            businessProvider.hasCompletedOnboarding;
        
        if (hasValidBusiness) {
          // Existing user with complete profile - go to home
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        } else {
          // New user OR incomplete profile - show onboarding
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
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: AppColors.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

