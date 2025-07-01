import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/hex_progress_indicator.dart';
import 'theme_selection_page.dart';
import 'location_hometown_page.dart';
import 'profile_info_page.dart';
import 'interest_tags_page.dart';
import 'skills_tools_page.dart';
import 'preview_confirm_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final provider = context.read<OnboardingProvider>();
    if (provider.currentPage < 5) {
      provider.goToNextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    final provider = context.read<OnboardingProvider>();
    if (provider.currentPage > 0) {
      provider.goToPrevPage();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int pageIndex) {
    final provider = context.read<OnboardingProvider>();
    provider.currentPage = pageIndex;
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Page content
                Expanded(
                  child: Container(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ThemeSelectionPage(),
                        LocationHometownPage(),
                        ProfileInfoPage(),
                        InterestTagsPage(),
                        SkillsToolsPage(),
                        PreviewConfirmPage(onComplete: () {
                          // Handle completion - use GoRouter to navigate to home
                          context.go('/');
                        }),
                      ],
                    ),
                  ),
                ),

                // Bottom navigation bar with Continue and Back buttons
                SafeArea(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                              .bottomNavigationBarTheme
                              .backgroundColor ??
                          Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Back button
                        if (provider.currentPage > 0)
                          ElevatedButton.icon(
                            onPressed: _prevPage,
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Back',
                                style: TextStyle(fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 60),
                        const Spacer(),
                        // Continue button
                        ElevatedButton(
                          onPressed: _canContinue(provider) ? _nextPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            provider.currentPage == 5 ? 'Complete' : 'Continue',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _canContinue(OnboardingProvider provider) {
    switch (provider.currentPage) {
      case 0: // Theme Selection
        return provider.themeSlug.isNotEmpty;
      case 1: // Location & Hometown
        return provider.currentLocation.isNotEmpty;
      case 2: // Profile Info
        return provider.firstName.isNotEmpty && provider.bio.isNotEmpty;
      case 3: // Interest Tags
        return provider.selectedInterests.isNotEmpty;
      case 4: // Skills & Tools
        return provider.selectedSkills.isNotEmpty;
      case 5: // Preview & Confirm
        return true; // Always can complete
      default:
        return false;
    }
  }
}
