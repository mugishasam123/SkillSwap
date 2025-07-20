import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/create_swap_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/swap/presentation/pages/swap_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => AuthBloc())],
      child: MaterialApp(
        title: 'SkillSwap',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashPage(),
          '/onboarding': (context) => const OnboardingPage(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const HomePage(),
          '/swap': (context) => const SwapPage(),
          '/create-swap': (context) => const CreateSwapPage(),
          '/messages': (context) => const MessagesPage(),
          '/profile': (context) => const ProfilePage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Messages Page')));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings Page')));
}
