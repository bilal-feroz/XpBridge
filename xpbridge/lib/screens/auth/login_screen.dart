import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../models/student_profile.dart';
import '../../models/startup_profile.dart';
import '../../models/startup_role.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!email.contains('@')) {
      return 'Email must contain @';
    }
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = _validateEmail(_emailController.text.trim());
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedRole = prefs.getString('user_role');
      final enteredEmail = _emailController.text.trim().toLowerCase();

      if (savedEmail == null || savedEmail != enteredEmail) {
        setState(() {
          _emailError = 'Account not found. Please sign up first.';
        });
        return;
      }

      if (!mounted) return;

      final appState = AppStateScope.of(context);
      final role = savedRole == 'student' ? UserRole.student : UserRole.startup;
      appState.login(role: role);

      // Restore profile data from shared_preferences
      if (role == UserRole.student) {
        final name = prefs.getString('profile_name');
        if (name != null && name.isNotEmpty) {
          final profile = StudentProfile(
            id: 'user_restored',
            name: name,
            email: savedEmail,
            bio: prefs.getString('profile_bio'),
            education: prefs.getString('profile_education'),
            skills: prefs.getStringList('profile_skills') ?? [],
            availabilityHours: prefs.getDouble('profile_hours') ?? 10,
            createdAt: DateTime.now(),
          );
          appState.saveStudentProfile(profile);
        }
        context.goNamed('studentDashboard');
      } else {
        final companyName = prefs.getString('startup_name');
        if (companyName != null && companyName.isNotEmpty) {
          final storedRoles = prefs.getString('startup_roles');
          final roles = storedRoles != null && storedRoles.isNotEmpty
              ? (jsonDecode(storedRoles) as List<dynamic>)
                  .map(
                    (item) => StartupRole.fromMap(
                      Map<String, dynamic>.from(item as Map),
                    ),
                  )
                  .where((role) => role.title.isNotEmpty)
                  .toList()
              : <StartupRole>[];
          final profile = StartupProfile(
            id: 'startup_restored',
            companyName: companyName,
            email: savedEmail,
            description: prefs.getString('startup_description') ?? '',
            industry: prefs.getString('startup_industry') ?? '',
            requiredSkills: prefs.getStringList('startup_skills') ?? [],
            openRoles: roles,
            projectDetails: prefs.getString('startup_project'),
            createdAt: DateTime.now(),
          );
          appState.saveStartupProfile(profile);
        }
        context.goNamed('startupDashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.primary.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Sign in to continue your journey',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              XPCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: _emailError != null ? Colors.red : null,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: _emailError != null
                              ? const BorderSide(color: Colors.red)
                              : BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: _emailError != null
                              ? const BorderSide(color: Colors.red)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _emailError != null
                                ? Colors.red
                                : AppTheme.primary,
                          ),
                        ),
                        filled: true,
                        fillColor: _emailError != null
                            ? Colors.red.withValues(alpha: 0.05)
                            : AppTheme.background,
                        errorText: _emailError,
                        errorStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: _passwordError != null ? Colors.red : null,
                        ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: _passwordError != null
                              ? const BorderSide(color: Colors.red)
                              : BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: _passwordError != null
                              ? const BorderSide(color: Colors.red)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _passwordError != null
                                ? Colors.red
                                : AppTheme.primary,
                          ),
                        ),
                        filled: true,
                        fillColor: _passwordError != null
                            ? Colors.red.withValues(alpha: 0.05)
                            : AppTheme.background,
                        errorText: _passwordError,
                        errorStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Forgot password flow
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    XPButton(
                      label: 'Sign In',
                      icon: Icons.login_rounded,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.goNamed('signup'),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
