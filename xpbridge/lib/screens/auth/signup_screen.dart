import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../services/user_file_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole? _selectedRole;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _roleError;

  @override
  void dispose() {
    _nameController.dispose();
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

  String? _validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  Future<void> _handleSignup() async {
    setState(() {
      _nameError = _validateName(_nameController.text.trim());
      _emailError = _validateEmail(_emailController.text.trim());
      _passwordError = _validatePassword(_passwordController.text);
      _roleError = _selectedRole == null ? 'Please select a role' : null;
    });

    if (_nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _roleError == null) {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final role = _selectedRole == UserRole.student ? 'student' : 'startup';

      // Check if user already exists in the txt file
      if (await UserFileService.userExists(email)) {
        setState(() {
          _emailError = 'Account already exists. Please login.';
        });
        return;
      }

      // Save user credentials to txt file
      final saved = await UserFileService.saveUser(email, password);
      if (!saved) {
        setState(() {
          _emailError = 'Failed to create account. Please try again.';
        });
        return;
      }

      // Still save other data to SharedPreferences for profile info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      await prefs.setString('user_role', role);

      if (!mounted) return;

      final appState = AppStateScope.of(context);
      appState.login(role: _selectedRole!);

      if (_selectedRole == UserRole.student) {
        context.goNamed('studentSetup');
      } else {
        context.goNamed('startupSetup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => context.goNamed('login'),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Header
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join XPBridge and start your journey',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Role selection
                const Text(
                  'I am a...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'Student',
                        subtitle: 'Looking to learn & grow',
                        icon: Icons.school_rounded,
                        isSelected: _selectedRole == UserRole.student,
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.student;
                            _roleError = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        title: 'Startup',
                        subtitle: 'Looking for talent',
                        icon: Icons.rocket_launch_rounded,
                        isSelected: _selectedRole == UserRole.startup,
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.startup;
                            _roleError = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (_roleError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _roleError!,
                    style: TextStyle(
                      color: AppTheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                // Form
                XPCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        hint: 'Enter your name',
                        error: _nameError,
                        onChanged: () {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        hint: 'Enter your email',
                        error: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: () {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.text,
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
                          hintText: 'Create a password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: _passwordError != null
                                ? AppTheme.error
                                : AppTheme.textMuted,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textMuted,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: _passwordError != null
                              ? AppTheme.error.withValues(alpha: 0.05)
                              : AppTheme.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: _passwordError != null
                                ? BorderSide(color: AppTheme.error)
                                : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: _passwordError != null
                                ? BorderSide(color: AppTheme.error)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _passwordError != null
                                  ? AppTheme.error
                                  : AppTheme.primary,
                              width: 2,
                            ),
                          ),
                          errorText: _passwordError,
                          errorStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 28),
                      XPButton(
                        label: 'Create Account',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _handleSignup,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.goNamed('login'),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? error,
    TextInputType? keyboardType,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: error != null ? AppTheme.error : AppTheme.textMuted,
            ),
            filled: true,
            fillColor: error != null
                ? AppTheme.error.withValues(alpha: 0.05)
                : AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  error != null ? BorderSide(color: AppTheme.error) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  error != null ? BorderSide(color: AppTheme.error) : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: error != null ? AppTheme.error : AppTheme.primary,
                width: 2,
              ),
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.cardBackground,
            width: 2,
          ),
          boxShadow: isSelected
              ? AppTheme.cardShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.1),
                          AppTheme.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primary.withValues(alpha: 0.8),
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.primary : AppTheme.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
