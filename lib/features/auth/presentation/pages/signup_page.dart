import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Green corner background
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_corner.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', height: 250),
                      const SizedBox(height: 12),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 32),
                      _SignupForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignupForm extends StatefulWidget {
  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF225B4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                              AuthSignupRequested(
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                confirmPassword: _confirmPasswordController.text,
                              ),
                            );
                      },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Account', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
} 