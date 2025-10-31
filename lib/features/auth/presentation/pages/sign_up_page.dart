import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/google_sign_in_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? AppStrings.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      // Only show error message if it's not a cancellation
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.signUp,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
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
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value != _passwordController.text) {
                      return AppStrings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return AuthButton(
                      text: AppStrings.signUp,
                      onPressed: authProvider.isLoading ? null : _handleSignUp,
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
                      onPressed: authProvider.isLoading ? null : _handleGoogleSignUp,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(color: AppColors.onBackground.withOpacity(0.7)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(AppRouter.login);
                      },
                      child: Text(
                        AppStrings.login,
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
    );
  }
}

