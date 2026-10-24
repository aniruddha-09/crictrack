// lib/app/router.dart
// go_router configuration with all app routes.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/auth/presentation/role_selection_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/sessions/presentation/sessions_screen.dart';
import '../features/session_detail/presentation/session_detail_screen.dart';
import '../features/record/presentation/setup_guide_screen.dart';
import '../features/record/presentation/recording_screen.dart';
import '../features/record/presentation/processing_screen.dart';
import '../features/record/presentation/upload_session_screen.dart';
import '../features/lbw/presentation/lbw_review_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/paywall_screen.dart';
import 'shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = auth.isLoggedIn;
      final location = state.matchedLocation;

      // Auth-gated routes
      final publicRoutes = ['/splash', '/login', '/otp', '/role'];
      final isPublic = publicRoutes.any((r) => location.startsWith(r));

      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && isPublic && location != '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (ctx, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/role',
        builder: (ctx, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return RoleSelectionScreen(phone: phone);
        },
      ),
      ShellRoute(
        builder: (ctx, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (ctx, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/sessions',
            builder: (ctx, state) => const SessionsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (ctx, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/setup',
        builder: (ctx, state) => const SetupGuideScreen(),
      ),
      GoRoute(
        path: '/recording',
        builder: (ctx, state) => const RecordingScreen(),
      ),
      GoRoute(
        path: '/processing',
        builder: (ctx, state) {
          final sessionId = state.uri.queryParameters['sessionId'] ?? '';
          return ProcessingScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/session/:id',
        builder: (ctx, state) {
          final id = state.pathParameters['id']!;
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return SessionDetailScreen(sessionId: id, initialTab: tab);
        },
      ),
      GoRoute(
        path: '/lbw',
        builder: (ctx, state) {
          final deliveryId = state.uri.queryParameters['deliveryId'] ?? '';
          final sessionId = state.uri.queryParameters['sessionId'] ?? '';
          return LbwReviewScreen(
            deliveryId: deliveryId,
            sessionId: sessionId,
          );
        },
      ),
      GoRoute(
        path: '/paywall',
        builder: (ctx, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/upload',
        builder: (ctx, state) => const UploadSessionScreen(),
      ),
    ],
  );
});
