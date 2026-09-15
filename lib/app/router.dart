import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../presentation/auth/login_screen.dart';
import '../presentation/auth/auth_controller.dart';
import '../presentation/recordings/recordings_screen.dart';
import '../presentation/recordings/recording_detail_screen.dart';
import '../presentation/recordings/upload_recording_screen.dart';
import '../presentation/system/system_status_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/recordings',
    refreshListenable: authState,
    observers: [
      _RouterLoggingObserver(),
    ],
    redirect: (context, state) {
      print('[Router] redirect check: '
          'location=${state.matchedLocation} '
          'full=${state.uri} '
          'isLogin=${state.matchedLocation == '/login'} '
          'isAuthed=${authState.value.isAuthenticated} '
          'isLoading=${authState.value.isLoading}');
      // Wait for API key restore before forcing a redirect.
      if (authState.value.isLoading) {
        return null;
      }
      final loc = state.matchedLocation;
      final isLogin = loc == '/login';
      final isSystem = loc == '/system';
      final isAuthed = authState.value.isAuthenticated;
      // Unauthenticated: allow System (API key setup) and Login.
      if (!isAuthed && !isLogin && !isSystem) {
        print('[Router] redirect -> /system (enter API key)');
        return '/system';
      }
      if (isAuthed && isLogin) {
        print('[Router] redirect -> /recordings');
        return '/recordings';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/recordings',
        builder: (context, state) => const RecordingsScreen(),
      ),
      GoRoute(
        path: '/recordings/:id',
        builder: (context, state) => RecordingDetailScreen(
          recordingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/recordings/offline/:id',
        builder: (context, state) => RecordingDetailScreen(
          recordingId: state.pathParameters['id']!,
          offline: true,
        ),
      ),
      GoRoute(
        path: '/upload-recording',
        builder: (context, state) => const UploadRecordingScreen(),
      ),
      GoRoute(
        path: '/system',
        builder: (context, state) => const SystemStatusScreen(),
      ),
    ],
  );
});

class _RouterLoggingObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('[Router] didPush: ${route.settings.name ?? route.settings} '
        'from=${previousRoute?.settings.name ?? previousRoute?.settings}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('[Router] didPop: ${route.settings.name ?? route.settings} '
        'to=${previousRoute?.settings.name ?? previousRoute?.settings}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('[Router] didReplace: '
        'new=${newRoute?.settings.name ?? newRoute?.settings} '
        'old=${oldRoute?.settings.name ?? oldRoute?.settings}');
  }
}
