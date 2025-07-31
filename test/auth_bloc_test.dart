import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_event.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_state.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, FirebaseFirestore, GoogleSignIn, User, UserCredential, GoogleSignInAccount, GoogleSignInAuthentication])
import 'auth_bloc_test.mocks.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuth = MockGoogleSignInAuthentication();

      // Setup default mock behaviors
      when(mockUser.uid).thenReturn('test-uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(mockUserCredential.user).thenReturn(mockUser);
    });

    tearDown(() {
      authBloc.close();
    });

    group('Login Flow', () {
      test('initial state should be AuthInitial', () {
        authBloc = AuthBloc();
        expect(authBloc.state, isA<AuthInitial>());
      });

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when login is successful',
        build: () {
          when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => mockUserCredential);
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails with invalid email',
        build: () {
          when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'invalid-email',
            password: 'password123',
          )).thenThrow(FirebaseAuthException(code: 'invalid-email'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: 'invalid-email',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'The email address is not valid.',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails with wrong password',
        build: () {
          when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'wrongpassword',
          )).thenThrow(FirebaseAuthException(code: 'wrong-password'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: 'test@example.com',
          password: 'wrongpassword',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'Incorrect password. Please try again.',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails with user not found',
        build: () {
          when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'nonexistent@example.com',
            password: 'password123',
          )).thenThrow(FirebaseAuthException(code: 'user-not-found'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: 'nonexistent@example.com',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'No user found for that email.',
          ),
        ],
      );
    });

    group('Signup Flow', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when signup is successful',
        build: () {
          when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'newuser@example.com',
            password: 'password123',
          )).thenAnswer((_) async => mockUserCredential);
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthSignupRequested(
          name: 'New User',
          email: 'newuser@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when passwords do not match',
        build: () => AuthBloc(),
        act: (bloc) => bloc.add(const AuthSignupRequested(
          name: 'New User',
          email: 'newuser@example.com',
          password: 'password123',
          confirmPassword: 'differentpassword',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'Passwords do not match',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when signup fails with email already in use',
        build: () {
          when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'existing@example.com',
            password: 'password123',
          )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthSignupRequested(
          name: 'Existing User',
          email: 'existing@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'This email is already in use.',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when signup fails with weak password',
        build: () {
          when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'user@example.com',
            password: '123',
          )).thenThrow(FirebaseAuthException(code: 'weak-password'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthSignupRequested(
          name: 'Weak Password User',
          email: 'user@example.com',
          password: '123',
          confirmPassword: '123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'The password is too weak.',
          ),
        ],
      );
    });

    group('Google Sign-In Flow', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when Google sign-in is successful for existing user',
        build: () {
          when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
          when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuth);
          when(mockGoogleSignInAuth.accessToken).thenReturn('access-token');
          when(mockGoogleSignInAuth.idToken).thenReturn('id-token');
          when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when Google sign-in is cancelled',
        build: () {
          when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'Google Sign-In was cancelled',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when Google sign-in fails with network error',
        build: () {
          when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
          when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuth);
          when(mockGoogleSignInAuth.accessToken).thenReturn('access-token');
          when(mockGoogleSignInAuth.idToken).thenReturn('id-token');
          when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'Network error. Please check your connection.',
          ),
        ],
      );
    });

    group('Sign Out Flow', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthInitial] when sign out is successful',
        build: () {
          when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
          when(mockFirebaseAuth.signOut()).thenAnswer((_) async => null);
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          isA<AuthInitial>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthFailure] when sign out fails',
        build: () {
          when(mockGoogleSignIn.signOut()).thenThrow(Exception('Sign out failed'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'Sign out failed. Please try again.',
          ),
        ],
      );
    });

    group('Error Handling', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login throws generic exception',
        build: () {
          when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenThrow(Exception('Generic error'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'Login failed. Please try again.',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when signup throws generic exception',
        build: () {
          when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'user@example.com',
            password: 'password123',
          )).thenThrow(Exception('Generic error'));
          
          return AuthBloc();
        },
        act: (bloc) => bloc.add(const AuthSignupRequested(
          name: 'Test User',
          email: 'user@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (failure) => failure.message,
            'message',
            'Signup failed. Please try again.',
          ),
        ],
      );
    });
  });
} 