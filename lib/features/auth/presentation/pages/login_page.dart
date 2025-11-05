import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../../../business/presentation/providers/business_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    
    final success = await authProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      try {
        final currentUserId = authProvider.user!.uid;
        
        // Clear any old business data first
        businessProvider.clearBusiness();
        
        // Load business for current user
        await businessProvider.loadBusiness(currentUserId);
        
        if (!mounted) return;
        
        final hasValidBusiness = businessProvider.business != null &&
            businessProvider.business!.userId == currentUserId &&
            businessProvider.hasCompletedOnboarding;
        
        if (hasValidBusiness) {
          // Existing user - go to home
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        } else {
          // Incomplete/New user - show onboarding
          Navigator.of(context).pushReplacementNamed(AppRouter.businessOnboarding);
        }
      } catch (e) {
        // On error, show business onboarding
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRouter.businessOnboarding);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? AppStrings.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      
      // Clear any old business data before signing in
      businessProvider.clearBusiness();
      
      final success = await authProvider.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        try {
          final currentUserId = authProvider.user!.uid;
          
          // Load business for current user
          await businessProvider.loadBusiness(currentUserId);
          
          if (!mounted) return;
          
          final hasValidBusiness = businessProvider.business != null &&
              businessProvider.business!.userId == currentUserId &&
              businessProvider.hasCompletedOnboarding;
          
          if (hasValidBusiness) {
            // Existing user - go to home
            Navigator.of(context).pushReplacementNamed(AppRouter.home);
          } else {
            // Incomplete/New user - show onboarding
            Navigator.of(context).pushReplacementNamed(AppRouter.businessOnboarding);
          }
        } catch (e) {
          debugPrint('Error loading business after sign in: $e');
          // On error, show business onboarding
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppRouter.businessOnboarding);
        }
      } else {
        // Only show error message if it's not a cancellation
        if (authProvider.errorMessage != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in Google Sign-In: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Animated Logo
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              size: 50,
                              color: AppColors.onPrimary,
                            ),
                            // TODO: Replace with: Image.asset('assets/images/logo.png')
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Animated Title
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
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
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue managing your business',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  AuthTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.emailRequired;
                    }
                    if (!value.contains('@')) {
                      return AppStrings.errorInvalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return AuthButton(
                      text: AppStrings.login,
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.onBackground.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppColors.onBackground.withOpacity(0.7)),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.onBackground.withOpacity(0.3))),
                  ],
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return GoogleSignInButton(
                      onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: TextStyle(color: AppColors.onBackground.withOpacity(0.7)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(AppRouter.signUp);
                      },
                      child: Text(
                        AppStrings.signUp,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

