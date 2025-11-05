import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../providers/onboarding_provider.dart';

class AppOnboardingPage extends StatefulWidget {
  const AppOnboardingPage({super.key});

  @override
  State<AppOnboardingPage> createState() => _AppOnboardingPageState();
}

class _AppOnboardingPageState extends State<AppOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: 'Manage Your Business',
      description: 'Complete billing solution with 11 document types. Create invoices, track payments, and manage inventory all in one place.',
      animationAsset: 'assets/images/invoice-maker.png',
      isImage: true,
    ),
    OnboardingContent(
      title: 'Smart Accounting',
      description: 'Auto-calculate GST, generate P&L statements, track ledgers, and stay compliant with real-time reports.',
      animationAsset: 'assets/images/ledgers.png',
      isImage: true,
    ),
    OnboardingContent(
      title: 'Get Paid Faster',
      description: 'UPI QR codes, payment tracking, and WhatsApp sharing. Get paid instantly and keep your cash flow healthy.',
      animationAsset: 'assets/images/invoice.png',
      isImage: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Future<void> _completeOnboarding() async {
    try {
      final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
      await onboardingProvider.completeOnboarding();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Dots Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation or Image
          if (content.isImage)
            Image.asset(
              content.animationAsset,
              height: 280,
              width: 280,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 100,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                );
              },
            )
          else
            Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Lottie.asset(
                content.animationAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.animation,
                    size: 100,
                    color: Colors.grey,
                  );
                },
              ),
            ),

          const SizedBox(height: 48),

          // Title
          Text(
            content.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            content.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String animationAsset;
  final bool isImage;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.animationAsset,
    this.isImage = false,
  });
}

