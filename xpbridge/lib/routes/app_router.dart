import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../data/dummy_data.dart';
import '../models/mission.dart';
import '../screens/missions/mission_details_screen.dart';
import '../screens/missions/mission_feed_screen.dart';
import '../screens/missions/mission_workspace_screen.dart';
import '../screens/missions/submission_success_screen.dart';
import '../screens/onboarding/age_band_screen.dart';
import '../screens/onboarding/role_select_screen.dart';
import '../screens/onboarding/student_setup_screen.dart';
import '../screens/passport/skills_passport_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRouter {
  AppRouter({required this.appState});

  final AppState appState;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: appState,
    routes: [
      GoRoute(
        name: 'splash',
        path: '/',
        pageBuilder: (context, state) => _fade(const SplashScreen()),
      ),
      GoRoute(
        name: 'roleSelect',
        path: '/role',
        pageBuilder: (context, state) => _slide(const RoleSelectScreen()),
      ),
      GoRoute(
        name: 'ageBand',
        path: '/age',
        pageBuilder: (context, state) => _slide(const AgeBandScreen()),
      ),
      GoRoute(
        name: 'studentSetup',
        path: '/setup',
        pageBuilder: (context, state) => _slide(const StudentSetupScreen()),
      ),
      GoRoute(
        name: 'missionFeed',
        path: '/missions',
        pageBuilder: (context, state) => _fade(const MissionFeedScreen()),
      ),
      GoRoute(
        name: 'missionDetails',
        path: '/missions/:id',
        pageBuilder: (context, state) {
          final mission = _resolveMission(state);
          return _slide(MissionDetailsScreen(mission: mission));
        },
      ),
      GoRoute(
        name: 'missionWorkspace',
        path: '/missions/:id/workspace',
        pageBuilder: (context, state) {
          final mission = _resolveMission(state);
          return _slide(MissionWorkspaceScreen(mission: mission));
        },
      ),
      GoRoute(
        name: 'submissionSuccess',
        path: '/submission-success',
        pageBuilder: (context, state) {
          final extras = state.extra is Map
              ? state.extra as Map
              : <String, dynamic>{};
          final Mission? mission = extras['mission'] as Mission?;
          final int xp = extras['xp'] as int? ?? mission?.xp ?? 60;
          return _fade(SubmissionSuccessScreen(mission: mission, xp: xp));
        },
      ),
      GoRoute(
        name: 'skillsPassport',
        path: '/passport',
        pageBuilder: (context, state) => _slide(const SkillsPassportScreen()),
      ),
    ],
  );

  Mission _resolveMission(GoRouterState state) {
    final mission = state.extra is Mission ? state.extra as Mission : null;
    if (mission != null) return mission;
    final id = state.pathParameters['id'];
    return DummyData.missions.firstWhere(
      (m) => m.id == id,
      orElse: () => DummyData.missions.first,
    );
  }

  static CustomTransitionPage _fade(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage _slide(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          ),
        );
      },
    );
  }
}
