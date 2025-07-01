import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'modules/crewsfeed/crewsfeed_page.dart';
import 'modules/events/events_page.dart';
import 'screens/my_profile_screen.dart';
import 'modules/projects/projects_page.dart';
import 'modules/projects/project_detail_page.dart';
import 'modules/marketplace/marketplace_page.dart';
import 'modules/auth/login_page.dart';
import 'modules/auth/signup_page.dart';
import 'modules/auth/verify_code_page.dart';
import 'modules/onboarding/onboarding_page.dart';
import 'widgets/base_layout.dart';
import 'screens/crews_screen.dart';
import 'screens/event_details_screen.dart';
import 'modules/projects/project_form.dart';
import 'screens/marketplace_detail_screen.dart';
import 'screens/crewsfeed_screen.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'providers/onboarding_provider.dart';

// Global navigator key for navigation from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  // Cache variables removed - onboarding check disabled
  // Cache variables removed - onboarding check disabled

  // Cache clearing method removed - onboarding check disabled

  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      navigatorKey: navigatorKey,
      refreshListenable: authService,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/verify-code',
          name: 'verify-code',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return VerifyCodePage(email: email);
          },
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/',
          redirect: (context, state) => '/onboarding',
        ),
        GoRoute(
          path: '/crewsfeed',
          builder: (context, state) =>
              const BaseLayout(child: CrewsFeedScreen()),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const BaseLayout(child: ProjectsPage()),
        ),
        GoRoute(
          path: '/crews',
          builder: (context, state) => const BaseLayout(child: CrewsScreen()),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const BaseLayout(child: EventsPage()),
        ),
        GoRoute(
          path: '/marketplace',
          builder: (context, state) =>
              const BaseLayout(child: MarketplacePage()),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const BaseLayout(child: MyProfileScreen()),
        ),
        GoRoute(
          path: '/project/:id',
          builder: (context, state) {
            return BaseLayout(
                child:
                    ProjectDetailPage(projectId: state.pathParameters['id']!));
          },
        ),
        GoRoute(
          path: '/event/:id',
          builder: (context, state) {
            final eventId = state.pathParameters['id']!;
            return BaseLayout(child: EventDetailsScreen(eventId: eventId));
          },
        ),
        GoRoute(
          path: '/listing/:id',
          builder: (context, state) {
            final listingId = state.pathParameters['id']!;
            return BaseLayout(
                child: MarketplaceDetailScreen(listingId: listingId));
          },
        ),
        GoRoute(
          path: '/project/:id/edit',
          builder: (context, state) {
            return BaseLayout(
              child: Scaffold(
                appBar: AppBar(title: const Text('Edit Project')),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ProjectForm(
                      project: null, // This will be fetched in the form
                      onSubmit: (project) {
                        context.pop();
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
