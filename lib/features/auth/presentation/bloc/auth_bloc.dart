import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
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

  Future<void> _onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        emit(const AuthFailure('Google Sign-In was cancelled'));
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user already exists in Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          // User exists, go to home
          emit(AuthSuccess());
        } else {
          // User doesn't exist, create basic user profile and redirect to profile completion
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName ?? '',
            'username': user.displayName?.toLowerCase().replaceAll(' ', '') ?? '',
            'swapScore': 0,
            'location': '',
            'availability': '',
            'skillsOffered': [],
            'skillsWanted': [],
            'reviews': [],
            'bio': '',
            'notificationsEnabled': true,
            'privacySettings': {},
            'avatarUrl': user.photoURL,
            'isProfileComplete': false,
          });
          emit(AuthNeedsProfileCompletion());
        }
      } else {
        emit(const AuthFailure('Google Sign-In failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'An account already exists with the same email address but different sign-in credentials.';
          break;
        case 'invalid-credential':
          message = 'The credential is invalid.';
          break;
        case 'operation-not-allowed':
          message = 'Google Sign-In is not enabled. Please contact support.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = 'Google Sign-In failed. Please try again.';
      }
      emit(AuthFailure(message));
    } catch (e) {
      emit(const AuthFailure('Google Sign-In failed. Please try again.'));
    }
  }

  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Sign out failed. Please try again.'));
    }
  }
} 