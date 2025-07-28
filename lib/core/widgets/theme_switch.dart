import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_bloc.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is ThemeLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.light_mode,
                  size: 20,
                  color: state.isDarkMode 
                      ? Colors.grey 
                      : Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: state.isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(ToggleThemeEvent());
                  },
                  activeColor: const Color(0xFF3E8E7E),
                  inactiveThumbColor: const Color(0xFF225B4B),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.dark_mode,
                  size: 20,
                  color: state.isDarkMode 
                      ? Theme.of(context).iconTheme.color 
                      : Colors.grey,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
} 