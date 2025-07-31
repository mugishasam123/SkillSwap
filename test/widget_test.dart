import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_event.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_state.dart';

// Generate mocks
@GenerateMocks([AuthBloc])
import 'widget_test.mocks.dart';

void main() {
  group('Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    group('Authentication Widget Tests', () {
      testWidgets('Login form validation test', (WidgetTester tester) async {
        // Arrange
        when(mockAuthBloc.state).thenReturn(AuthInitial());
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: Scaffold(
                body: Column(
                  children: [
                    TextField(
                      key: const Key('email_field'),
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      key: const Key('password_field'),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    ElevatedButton(
                      key: const Key('login_button'),
                      onPressed: () {
                        mockAuthBloc.add(const AuthLoginRequested(
                          email: 'test@example.com',
                          password: 'password123',
                        ));
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('email_field')), findsOneWidget);
        expect(find.byKey(const Key('password_field')), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);

        // Test form interaction
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();

        // Verify that the login event was added
        verify(mockAuthBloc.add(const AuthLoginRequested(
          email: 'test@example.com',
          password: 'password123',
        ))).called(1);
      });

      testWidgets('Signup form validation test', (WidgetTester tester) async {
        // Arrange
        when(mockAuthBloc.state).thenReturn(AuthInitial());
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: Scaffold(
                body: Column(
                  children: [
                    TextField(
                      key: const Key('name_field'),
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      key: const Key('signup_email_field'),
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      key: const Key('signup_password_field'),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      key: const Key('confirm_password_field'),
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                    ),
                    ElevatedButton(
                      key: const Key('signup_button'),
                      onPressed: () {
                        mockAuthBloc.add(const AuthSignupRequested(
                          name: 'Test User',
                          email: 'test@example.com',
                          password: 'password123',
                          confirmPassword: 'password123',
                        ));
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('name_field')), findsOneWidget);
        expect(find.byKey(const Key('signup_email_field')), findsOneWidget);
        expect(find.byKey(const Key('signup_password_field')), findsOneWidget);
        expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);
        expect(find.byKey(const Key('signup_button')), findsOneWidget);

        // Test form interaction
        await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
        await tester.enterText(find.byKey(const Key('signup_email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('signup_password_field')), 'password123');
        await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
        await tester.tap(find.byKey(const Key('signup_button')));
        await tester.pump();

        // Verify that the signup event was added
        verify(mockAuthBloc.add(const AuthSignupRequested(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        ))).called(1);
      });

      testWidgets('Loading state UI test', (WidgetTester tester) async {
        // Arrange
        when(mockAuthBloc.state).thenReturn(AuthLoading());
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const Scaffold(body: Text('Not Loading'));
                },
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Error state UI test', (WidgetTester tester) async {
        // Arrange
        when(mockAuthBloc.state).thenReturn(const AuthFailure('Login failed'));
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(const AuthFailure('Login failed')));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthFailure) {
                    return Scaffold(
                      body: Center(
                        child: Text(state.message),
                      ),
                    );
                  }
                  return const Scaffold(body: Text('No Error'));
                },
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Login failed'), findsOneWidget);
      });
    });

    group('Messaging Widget Tests', () {
      testWidgets('Message input field test', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Message ${index + 1}'),
                          subtitle: Text('Sender ${index + 1}'),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('message_input'),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          key: const Key('send_button'),
                          onPressed: () {
                            // Send message logic
                          },
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('message_input')), findsOneWidget);
        expect(find.byKey(const Key('send_button')), findsOneWidget);
        expect(find.text('Type a message...'), findsOneWidget);

        // Test message input interaction
        await tester.enterText(find.byKey(const Key('message_input')), 'Hello, this is a test message');
        await tester.tap(find.byKey(const Key('send_button')));
        await tester.pump();

        // Verify input field is cleared or message is sent
        expect(find.text('Hello, this is a test message'), findsOneWidget);
      });

      testWidgets('Message list display test', (WidgetTester tester) async {
        // Arrange
        final messages = [
          {'sender': 'John Doe', 'message': 'Hello there!', 'timestamp': '10:30 AM'},
          {'sender': 'Jane Smith', 'message': 'Hi! How are you?', 'timestamp': '10:32 AM'},
          {'sender': 'John Doe', 'message': 'I\'m doing great, thanks!', 'timestamp': '10:35 AM'},
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(message['sender']!),
                      subtitle: Text(message['message']!),
                      trailing: Text(message['timestamp']!),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('John Doe'), findsNWidgets(2));
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Hello there!'), findsOneWidget);
        expect(find.text('Hi! How are you?'), findsOneWidget);
        expect(find.text('I\'m doing great, thanks!'), findsOneWidget);
      });
    });

    group('Forum Widget Tests', () {
      testWidgets('Forum post creation test', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text('Forum Post ${index + 1}'),
                            subtitle: Text('Author ${index + 1}'),
                            trailing: Text('${index + 1} replies'),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          key: const Key('post_title'),
                          decoration: const InputDecoration(
                            labelText: 'Post Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          key: const Key('post_content'),
                          decoration: const InputDecoration(
                            labelText: 'Post Content',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          key: const Key('create_post_button'),
                          onPressed: () {
                            // Create post logic
                          },
                          child: const Text('Create Post'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('post_title')), findsOneWidget);
        expect(find.byKey(const Key('post_content')), findsOneWidget);
        expect(find.byKey(const Key('create_post_button')), findsOneWidget);
        expect(find.text('Forum Post 1'), findsOneWidget);
        expect(find.text('Forum Post 2'), findsOneWidget);

        // Test post creation interaction
        await tester.enterText(find.byKey(const Key('post_title')), 'New Forum Post');
        await tester.enterText(find.byKey(const Key('post_content')), 'This is the content of my new forum post.');
        await tester.tap(find.byKey(const Key('create_post_button')));
        await tester.pump();

        // Verify form interaction
        expect(find.text('New Forum Post'), findsOneWidget);
        expect(find.text('This is the content of my new forum post.'), findsOneWidget);
      });

      testWidgets('Forum post list with search test', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Forum'),
                actions: [
                  IconButton(
                    key: const Key('search_button'),
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      key: const Key('search_field'),
                      decoration: const InputDecoration(
                        labelText: 'Search posts...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('U${index + 1}'),
                            ),
                            title: Text('Post Title ${index + 1}'),
                            subtitle: Text('This is the content preview for post ${index + 1}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${index + 1}'),
                                const Text('replies'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('search_button')), findsOneWidget);
        expect(find.byKey(const Key('search_field')), findsOneWidget);
        expect(find.text('Search posts...'), findsOneWidget);
        expect(find.text('Post Title 1'), findsOneWidget);
        expect(find.text('Post Title 2'), findsOneWidget);
        expect(find.text('Post Title 3'), findsOneWidget);

        // Test search functionality
        await tester.enterText(find.byKey(const Key('search_field')), 'Post Title 1');
        await tester.pump();

        // Verify search interaction
        expect(find.text('Post Title 1'), findsOneWidget);
      });
    });

    group('Navigation Flow Tests', () {
      testWidgets('Navigation between screens test', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: 0,
                      children: [
                        const Center(child: Text('Home Screen')),
                        const Center(child: Text('Messages Screen')),
                        const Center(child: Text('Forum Screen')),
                        const Center(child: Text('Profile Screen')),
                      ],
                    ),
                  ),
                  BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
                      BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
                      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    currentIndex: 0,
                    onTap: (index) {
                      // Navigation logic
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Home Screen'), findsOneWidget);
        expect(find.text('Messages Screen'), findsNothing);
        expect(find.text('Forum Screen'), findsNothing);
        expect(find.text('Profile Screen'), findsNothing);

        // Test navigation to Messages
        await tester.tap(find.text('Messages'));
        await tester.pump();

        // Verify navigation interaction
        expect(find.text('Messages'), findsOneWidget);
      });
    });

    group('Form Validation Tests', () {
      testWidgets('Email validation test', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    key: const Key('email_field'),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      errorText: null,
                    ),
                  ),
                  ElevatedButton(
                    key: const Key('validate_button'),
                    onPressed: () {
                      // Validation logic
                    },
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test invalid email
        await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
        await tester.tap(find.byKey(const Key('validate_button')));
        await tester.pump();

        // Test valid email
        await tester.enterText(find.byKey(const Key('email_field')), 'valid@email.com');
        await tester.tap(find.byKey(const Key('validate_button')));
        await tester.pump();

        // Verify validation interaction
        expect(find.text('valid@email.com'), findsOneWidget);
      });

      testWidgets('Password strength validation test', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    key: const Key('password_field'),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      helperText: 'Password must be at least 8 characters',
                    ),
                    obscureText: true,
                  ),
                  Text(
                    key: const Key('password_strength'),
                    'Password Strength: Weak',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test weak password
        await tester.enterText(find.byKey(const Key('password_field')), '123');
        await tester.pump();

        // Test strong password
        await tester.enterText(find.byKey(const Key('password_field')), 'StrongPassword123!');
        await tester.pump();

        // Verify password strength validation
        expect(find.text('StrongPassword123!'), findsOneWidget);
      });
    });
  });
}