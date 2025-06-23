import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'modules/crewsfeed/crewsfeed_page.dart';
import 'modules/events/events_page.dart';
import 'screens/my_profile_screen.dart';
import 'modules/projects/projects_page.dart';
import 'modules/projects/project_detail_page.dart';
import 'modules/marketplace/marketplace_page.dart';
import 'modules/auth/login_page.dart';
import 'modules/auth/signup_page.dart';
import 'widgets/crossbeam_header.dart';
import 'widgets/base_layout.dart';
import 'screens/crews_screen.dart';
import 'screens/crew_detail_page.dart';
import 'screens/subcrew_threads_page.dart';
import 'models/crew.dart';
import 'models/project.dart';
import 'screens/event_details_screen.dart';
import 'modules/projects/project_form.dart';
import 'screens/marketplace_detail_screen.dart';
import 'screens/project_details_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/thread_detail_page.dart';
import 'models/listing.dart';
import 'models/event.dart';
import 'models/marketplace_item.dart';
import 'models/user_profile.dart';
import 'pages/comment_page.dart';
import 'services/auth_service.dart';

class AppRouter {
  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      redirect: (context, state) {
        final loggedIn = authService.isAuthenticated;
        final isLoggingIn = state.uri.toString() == '/login' ||
            state.uri.toString() == '/signup';

        if (!loggedIn && !isLoggingIn) return '/login';
        if (loggedIn && isLoggingIn) return '/';
        return null;
      },
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
          path: '/',
          builder: (context, state) => const BaseLayout(child: CrewsfeedPage()),
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
            final projectId = state.pathParameters['id']!;
            return BaseLayout(child: ProjectDetailPage(projectId: projectId));
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
            final projectId = state.pathParameters['id']!;
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
