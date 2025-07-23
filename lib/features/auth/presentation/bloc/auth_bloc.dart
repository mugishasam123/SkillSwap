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
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      emit(AuthFailure(message));
    } catch (e) {
      emit(AuthFailure('Login failed. Please try again.'));
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
          'username': event.name.trim().toLowerCase().replaceAll(' ', ''),
          'swapScore': 0,
          'location': '',
          'availability': '',
          'skillsOffered': [],
          'skillsWanted': [],
          'reviews': [],
          'bio': '',
          'notificationsEnabled': true,
          'privacySettings': {},
        });
        emit(AuthSuccess());
      } else {
        emit(const AuthFailure('Signup failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already in use.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Operation not allowed. Please contact support.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        default:
          message = 'Signup failed. Please try again.';
      }
      emit(AuthFailure(message));
    } catch (e) {
      emit(const AuthFailure('Signup failed. Please try again.'));
    }
  }
} 