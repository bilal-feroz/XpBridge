import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpbridge/routes/app_router.dart';
import 'package:xpbridge/theme/app_theme.dart';

import 'models/application.dart';
import 'models/student_profile.dart';
import 'models/startup_profile.dart';

enum UserRole { student, startup }

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  UserRole? _userRole;
  StudentProfile? _studentProfile;
  StartupProfile? _startupProfile;
  List<Application> _applications = [];

  bool get isLoggedIn => _isLoggedIn;
  UserRole? get userRole => _userRole;
  StudentProfile? get studentProfile => _studentProfile;
  StartupProfile? get startupProfile => _startupProfile;
  List<Application> get applications => _applications;

  bool get isStudent => _userRole == UserRole.student;
  bool get isStartup => _userRole == UserRole.startup;

  void login({required UserRole role}) {
    _isLoggedIn = true;
    _userRole = role;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userRole = null;
    _studentProfile = null;
    _startupProfile = null;
    _applications = [];
    notifyListeners();
  }

  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  void saveStudentProfile(StudentProfile profile) {
    _studentProfile = profile;
    notifyListeners();
  }

  void saveStartupProfile(StartupProfile profile) {
    _startupProfile = profile;
    notifyListeners();
  }

  void addApplication(Application application) {
    _applications = [..._applications, application];
    notifyListeners();
  }

  void updateApplicationStatus(String applicationId, ApplicationStatus status) {
    _applications = _applications.map((app) {
      if (app.id == applicationId) {
        return app.copyWith(status: status, updatedAt: DateTime.now());
      }
      return app;
    }).toList();
    notifyListeners();
  }

  List<Application> getApplicationsForStudent(String studentId) {
    return _applications.where((app) => app.studentId == studentId).toList();
  }

  List<Application> getApplicationsForStartup(String startupId) {
    return _applications.where((app) => app.startupId == startupId).toList();
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
