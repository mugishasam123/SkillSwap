import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/theme_service.dart';

// Events
abstract class ThemeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ThemeInitialEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

// States
abstract class ThemeState extends Equatable {
  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  
  ThemeLoaded(this.isDarkMode);
  
  @override
  List<Object> get props => [isDarkMode];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeInitialEvent>(_onThemeInitial);
    on<ToggleThemeEvent>(_onToggleTheme);
  }
  
  void _onThemeInitial(ThemeInitialEvent event, Emitter<ThemeState> emit) async {
    final isDarkMode = await ThemeService.isDarkMode();
    emit(ThemeLoaded(isDarkMode));
  }
  
  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      final newTheme = !currentState.isDarkMode;
      await ThemeService.setDarkMode(newTheme);
      emit(ThemeLoaded(newTheme));
    }
  }
} 