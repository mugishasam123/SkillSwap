import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthFailure('Login failed'));
    }
  }

  Future<void> _onSignupRequested(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    if (event.password != event.confirmPassword) {
      emit(const AuthFailure('Passwords do not match'));
      return;
    }
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': event.name.trim(),
          'email': user.email,
          'swapScore': 0,
          'location': '',
          'availability': [],
          'skillLibrary': [],
          'reviews': [],
          'bio': '',
          'notificationsEnabled': true,
          'privacySettings': {},
        });
        emit(AuthSuccess());
      } else {
        emit(const AuthFailure('Signup failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Signup failed'));
    } catch (e) {
      emit(const AuthFailure('Signup failed'));
    }
  }
} 