import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/settings_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/swap/presentation/pages/swap_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/messages/presentation/pages/message_list_page.dart';
import 'features/home/presentation/pages/about_page.dart';
import 'core/theme/theme_bloc.dart';
import 'core/theme/app_theme.dart';

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()..add(ThemeInitialEvent())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'SkillSwap',
            debugShowCheckedModeBanner: false, // Disable the debug banner
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState is ThemeLoaded && themeState.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashPage(),
              '/onboarding': (context) => const OnboardingPage(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
              '/home': (context) => HomePage(arguments: ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?),
              '/swap': (context) => const SwapPage(),
              '/messages': (context) => MessageListPage(),
              '/profile': (context) => const ProfilePage(),
              '/settings': (context) => const SettingsPage(),
              '/about': (context) => const AboutPage(),
            },
          );
        },
      ),
    );
  }
}
