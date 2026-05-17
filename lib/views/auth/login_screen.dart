import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/theme/theme_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/inputs/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final ok = await auth.login(_userCtrl.text.trim(), _passCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      final role = auth.role;
      if (role == AppConstants.roleAdmin) context.go(AppConstants.routeAdminDashboard);
      else if (role == AppConstants.roleTeacher) context.go(AppConstants.routeTeacherDashboard);
      else context.go(AppConstants.routeStudentDashboard);
    }
  }


  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final theme = context.watch<ThemeViewModel>();
    final cs = Theme.of(context).colorScheme;
    final isDark = theme.isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0A0F1E), Color(0xFF111827)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF0F4FF), Color(0xFFE8EEFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Theme toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => context.read<ThemeViewModel>().toggle(),
                        icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Logo
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(child: Text('🏫', style: TextStyle(fontSize: 40))),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to your school portal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),



                  // Username
                  CustomTextField(
                    controller: _userCtrl,
                    label: 'Username',
                    hint: 'Enter your username',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Username required' : null,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 14),

                  // Password
                  CustomTextField(
                    controller: _passCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Password required' : null,
                  ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),

                  // Error message
                  if (auth.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(auth.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  CustomButton(
                    label: 'Sign In',
                    onPressed: _login,
                    isLoading: auth.isLoading,
                    icon: Icons.login_rounded,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 28),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
