import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpbridge/routes/app_router.dart';
import 'package:xpbridge/theme/app_theme.dart';

import 'models/mission.dart';
import 'models/user_profile.dart';

enum AgeBand { teen, adult }

extension AgeBandLabel on AgeBand {
  String get label => this == AgeBand.teen ? '15-17' : '18-21';
  String get description =>
      this == AgeBand.teen ? 'Guardrails on hours and safety' : 'Full access';
}

class AppState extends ChangeNotifier {
  AgeBand? ageBand;
  UserProfile? profile;
  Mission? activeMission;

  bool get isTeen => ageBand == AgeBand.teen;

  void setAgeBand(AgeBand band) {
    ageBand = band;
    notifyListeners();
  }

  void saveProfile(UserProfile value) {
    profile = value;
    notifyListeners();
  }

  void setActiveMission(Mission mission) {
    activeMission = mission;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}

class XPBridgeApp extends StatefulWidget {
  const XPBridgeApp({super.key});

  @override
  State<XPBridgeApp> createState() => _XPBridgeAppState();
}

class _XPBridgeAppState extends State<XPBridgeApp> {
  late final AppState _state;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _state = AppState();
    _router = AppRouter(appState: _state).router;
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _state,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'XPBridge',
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
