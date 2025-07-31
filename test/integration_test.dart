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
import 'integration_test.mocks.dart';

void main() {
  group('Integration Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    group('Complete User Authentication Flow', () {
      testWidgets('Full authentication flow from login to home screen', (WidgetTester tester) async {
        // Arrange
        when(mockAuthBloc.state).thenReturn(AuthInitial());
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

        // Act - Start with login screen
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: Scaffold(
                appBar: AppBar(title: const Text('Login')),
                body: Column(
                  children: [
                    TextField(
                      key: const Key('login_email'),
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      key: const Key('login_password'),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    ElevatedButton(
                      key: const Key('login_submit'),
                      onPressed: () {
                        mockAuthBloc.add(const AuthLoginRequested(
                          email: 'user@example.com',
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

        // Assert - Verify login screen elements
        expect(find.text('Login'), findsOneWidget);
        expect(find.byKey(const Key('login_email')), findsOneWidget);
        expect(find.byKey(const Key('login_password')), findsOneWidget);
        expect(find.byKey(const Key('login_submit')), findsOneWidget);

        // Act - Fill login form and submit
        await tester.enterText(find.byKey(const Key('login_email')), 'user@example.com');
        await tester.enterText(find.byKey(const Key('login_password')), 'password123');
        await tester.tap(find.byKey(const Key('login_submit')));
        await tester.pump();

        // Verify login event was triggered
        verify(mockAuthBloc.add(const AuthLoginRequested(
          email: 'user@example.com',
          password: 'password123',
        ))).called(1);

        // Act - Simulate successful login
        when(mockAuthBloc.state).thenReturn(AuthSuccess());
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthSuccess()));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthSuccess) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('SkillSwap Home')),
                      body: const Center(
                        child: Text('Welcome to SkillSwap!'),
                      ),
                      bottomNavigationBar: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        items: const [
                          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
                          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
                          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
                          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                        ],
                        currentIndex: 0,
                        onTap: (index) {},
                      ),
                    );
                  }
                  return const Scaffold(body: Text('Not Authenticated'));
                },
              ),
            ),
          ),
        );

        // Assert - Verify successful authentication and home screen
        expect(find.text('SkillSwap Home'), findsOneWidget);
        expect(find.text('Welcome to SkillSwap!'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Discover'), findsOneWidget);
        expect(find.text('Messages'), findsOneWidget);
        expect(find.text('Forum'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('Registration flow with profile completion', (WidgetTester tester) async {
        // Arrange
        when(mockAuthBloc.state).thenReturn(AuthInitial());
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

        // Act - Start with registration screen
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: Scaffold(
                appBar: AppBar(title: const Text('Sign Up')),
                body: Column(
                  children: [
                    TextField(
                      key: const Key('reg_name'),
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      key: const Key('reg_email'),
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      key: const Key('reg_password'),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      key: const Key('reg_confirm_password'),
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                    ),
                    ElevatedButton(
                      key: const Key('reg_submit'),
                      onPressed: () {
                        mockAuthBloc.add(const AuthSignupRequested(
                          name: 'John Doe',
                          email: 'john@example.com',
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

        // Assert - Verify registration screen elements
        expect(find.text('Sign Up'), findsOneWidget);
        expect(find.byKey(const Key('reg_name')), findsOneWidget);
        expect(find.byKey(const Key('reg_email')), findsOneWidget);
        expect(find.byKey(const Key('reg_password')), findsOneWidget);
        expect(find.byKey(const Key('reg_confirm_password')), findsOneWidget);

        // Act - Fill registration form and submit
        await tester.enterText(find.byKey(const Key('reg_name')), 'John Doe');
        await tester.enterText(find.byKey(const Key('reg_email')), 'john@example.com');
        await tester.enterText(find.byKey(const Key('reg_password')), 'password123');
        await tester.enterText(find.byKey(const Key('reg_confirm_password')), 'password123');
        await tester.tap(find.byKey(const Key('reg_submit')));
        await tester.pump();

        // Verify registration event was triggered
        verify(mockAuthBloc.add(const AuthSignupRequested(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        ))).called(1);

        // Act - Simulate successful registration and profile completion
        when(mockAuthBloc.state).thenReturn(AuthNeedsProfileCompletion());
        when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthNeedsProfileCompletion()));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthNeedsProfileCompletion) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Complete Profile')),
                      body: Column(
                        children: [
                          const Text('Please complete your profile'),
                          TextField(
                            key: const Key('profile_bio'),
                            decoration: const InputDecoration(labelText: 'Bio'),
                          ),
                          TextField(
                            key: const Key('profile_location'),
                            decoration: const InputDecoration(labelText: 'Location'),
                          ),
                          ElevatedButton(
                            key: const Key('profile_submit'),
                            onPressed: () {
                              // Profile completion logic
                            },
                            child: const Text('Complete Profile'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Scaffold(body: Text('Not in profile completion'));
                },
              ),
            ),
          ),
        );

        // Assert - Verify profile completion screen
        expect(find.text('Complete Profile'), findsOneWidget);
        expect(find.text('Please complete your profile'), findsOneWidget);
        expect(find.byKey(const Key('profile_bio')), findsOneWidget);
        expect(find.byKey(const Key('profile_location')), findsOneWidget);
        expect(find.byKey(const Key('profile_submit')), findsOneWidget);
      });
    });

    group('Skill Discovery and Matching Flow', () {
      testWidgets('Complete skill discovery and matching process', (WidgetTester tester) async {
        // Act - Start with authenticated home screen
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('SkillSwap')),
              body: Column(
                children: [
                  // Skill search section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          key: const Key('skill_search'),
                          decoration: const InputDecoration(
                            labelText: 'Search for skills...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              key: const Key('skill_programming'),
                              label: const Text('Programming'),
                              selected: true,
                              onSelected: (selected) {},
                            ),
                            FilterChip(
                              key: const Key('skill_design'),
                              label: const Text('Design'),
                              selected: false,
                              onSelected: (selected) {},
                            ),
                            FilterChip(
                              key: const Key('skill_music'),
                              label: const Text('Music'),
                              selected: false,
                              onSelected: (selected) {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Skill matches section
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('U${index + 1}'),
                            ),
                            title: Text('User ${index + 1}'),
                            subtitle: Text('Offers: Programming, Design'),
                            trailing: ElevatedButton(
                              key: Key('connect_${index + 1}'),
                              onPressed: () {},
                              child: const Text('Connect'),
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

        // Assert - Verify skill discovery elements
        expect(find.text('SkillSwap'), findsOneWidget);
        expect(find.byKey(const Key('skill_search')), findsOneWidget);
        expect(find.text('Search for skills...'), findsOneWidget);
        expect(find.text('Programming'), findsOneWidget);
        expect(find.text('Design'), findsOneWidget);
        expect(find.text('Music'), findsOneWidget);
        expect(find.text('User 1'), findsOneWidget);
        expect(find.text('User 2'), findsOneWidget);
        expect(find.text('User 3'), findsOneWidget);

        // Act - Search for specific skills
        await tester.enterText(find.byKey(const Key('skill_search')), 'Flutter');
        await tester.pump();

        // Act - Select a skill filter
        await tester.tap(find.byKey(const Key('skill_design')));
        await tester.pump();

        // Act - Connect with a user
        await tester.tap(find.byKey(const Key('connect_1')));
        await tester.pump();

        // Verify search and filter interactions
        expect(find.text('Flutter'), findsOneWidget);
      });
    });

    group('Messaging and Communication Flow', () {
      testWidgets('Complete messaging flow from connection to conversation', (WidgetTester tester) async {
        // Act - Start with messages list
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Messages')),
              body: Column(
                children: [
                  // Messages list
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return ListTile(
                          key: Key('message_${index + 1}'),
                          leading: CircleAvatar(
                            child: Text('U${index + 1}'),
                          ),
                          title: Text('User ${index + 1}'),
                          subtitle: Text('Last message: ${index == 0 ? 'Hello there!' : 'How are you?'}'),
                          trailing: Text('${index + 1}m ago'),
                          onTap: () {
                            // Navigate to conversation
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert - Verify messages list
        expect(find.text('Messages'), findsOneWidget);
        expect(find.text('User 1'), findsOneWidget);
        expect(find.text('User 2'), findsOneWidget);
        expect(find.text('Hello there!'), findsOneWidget);
        expect(find.text('How are you?'), findsOneWidget);

        // Act - Tap on a conversation
        await tester.tap(find.byKey(const Key('message_1')));
        await tester.pump();

        // Act - Navigate to conversation screen
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('User 1'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
              ),
              body: Column(
                children: [
                  // Messages in conversation
                  Expanded(
                    child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final isMe = index % 2 == 0;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Message ${index + 1}',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Message input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('conversation_input'),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          key: const Key('send_message'),
                          onPressed: () {},
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

        // Assert - Verify conversation screen
        expect(find.text('User 1'), findsOneWidget);
        expect(find.text('Message 1'), findsOneWidget);
        expect(find.text('Message 2'), findsOneWidget);
        expect(find.text('Message 3'), findsOneWidget);
        expect(find.text('Message 4'), findsOneWidget);
        expect(find.byKey(const Key('conversation_input')), findsOneWidget);
        expect(find.byKey(const Key('send_message')), findsOneWidget);

        // Act - Send a message
        await tester.enterText(find.byKey(const Key('conversation_input')), 'Hello! How are you?');
        await tester.tap(find.byKey(const Key('send_message')));
        await tester.pump();

        // Verify message sending
        expect(find.text('Hello! How are you?'), findsOneWidget);
      });
    });

    group('Forum Participation Flow', () {
      testWidgets('Complete forum participation flow', (WidgetTester tester) async {
        // Act - Start with forum list
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Forum'),
                actions: [
                  IconButton(
                    key: const Key('create_post_button'),
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Forum posts list
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            key: Key('post_${index + 1}'),
                            leading: CircleAvatar(
                              child: Text('U${index + 1}'),
                            ),
                            title: Text('Forum Post ${index + 1}'),
                            subtitle: Text('This is the content preview for post ${index + 1}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${index + 1}'),
                                const Text('replies'),
                              ],
                            ),
                            onTap: () {
                              // Navigate to post details
                            },
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

        // Assert - Verify forum list
        expect(find.text('Forum'), findsOneWidget);
        expect(find.byKey(const Key('create_post_button')), findsOneWidget);
        expect(find.text('Forum Post 1'), findsOneWidget);
        expect(find.text('Forum Post 2'), findsOneWidget);
        expect(find.text('Forum Post 3'), findsOneWidget);

        // Act - Tap on a post
        await tester.tap(find.byKey(const Key('post_1')));
        await tester.pump();

        // Act - Navigate to post details
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Forum Post 1'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
              ),
              body: Column(
                children: [
                  // Post content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(child: Text('U1')),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('User 1', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('2 hours ago', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This is the full content of Forum Post 1. It contains detailed information about the topic being discussed.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Replies
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(child: Text('U${index + 2}')),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('User ${index + 2}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('${index + 1} hour ago', style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Reply ${index + 1}: This is a reply to the forum post.'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Reply input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('reply_input'),
                            decoration: const InputDecoration(
                              hintText: 'Write a reply...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          key: const Key('submit_reply'),
                          onPressed: () {},
                          child: const Text('Reply'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert - Verify post details
        expect(find.text('Forum Post 1'), findsOneWidget);
        expect(find.text('User 1'), findsOneWidget);
        expect(find.text('User 2'), findsOneWidget);
        expect(find.text('User 3'), findsOneWidget);
        expect(find.text('Reply 1: This is a reply to the forum post.'), findsOneWidget);
        expect(find.text('Reply 2: This is a reply to the forum post.'), findsOneWidget);
        expect(find.byKey(const Key('reply_input')), findsOneWidget);
        expect(find.byKey(const Key('submit_reply')), findsOneWidget);

        // Act - Write and submit a reply
        await tester.enterText(find.byKey(const Key('reply_input')), 'This is my reply to the post.');
        await tester.tap(find.byKey(const Key('submit_reply')));
        await tester.pump();

        // Verify reply submission
        expect(find.text('This is my reply to the post.'), findsOneWidget);
      });
    });

    group('Profile Management Flow', () {
      testWidgets('Complete profile management flow', (WidgetTester tester) async {
        // Act - Start with profile screen
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
                actions: [
                  IconButton(
                    key: const Key('edit_profile'),
                    icon: const Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('john@example.com', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text('15', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const Text('Connections'),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('8', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const Text('Skills Offered'),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('5', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const Text('Skills Wanted'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Skills sections
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          key: const Key('skills_offered'),
                          leading: const Icon(Icons.offline_bolt),
                          title: const Text('Skills Offered'),
                          subtitle: const Text('Programming, Design, Music'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                        ListTile(
                          key: const Key('skills_wanted'),
                          leading: const Icon(Icons.search),
                          title: const Text('Skills Wanted'),
                          subtitle: const Text('Cooking, Photography'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                        ListTile(
                          key: const Key('settings'),
                          leading: const Icon(Icons.settings),
                          title: const Text('Settings'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                        ListTile(
                          key: const Key('logout'),
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert - Verify profile screen
        expect(find.text('Profile'), findsOneWidget);
        expect(find.byKey(const Key('edit_profile')), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('john@example.com'), findsOneWidget);
        expect(find.text('15'), findsOneWidget);
        expect(find.text('Connections'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
        expect(find.text('Skills Offered'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('Skills Wanted'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Logout'), findsOneWidget);

        // Act - Tap on skills offered
        await tester.tap(find.byKey(const Key('skills_offered')));
        await tester.pump();

        // Act - Navigate to skills management
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Skills Offered'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final skills = ['Programming', 'Design', 'Music'];
                        return ListTile(
                          key: Key('skill_${index + 1}'),
                          title: Text(skills[index]),
                          trailing: IconButton(
                            key: Key('remove_skill_${index + 1}'),
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {},
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      key: const Key('add_skill'),
                      onPressed: () {},
                      child: const Text('Add Skill'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert - Verify skills management
        expect(find.text('Skills Offered'), findsOneWidget);
        expect(find.text('Programming'), findsOneWidget);
        expect(find.text('Design'), findsOneWidget);
        expect(find.text('Music'), findsOneWidget);
        expect(find.byKey(const Key('add_skill')), findsOneWidget);

        // Act - Add a new skill
        await tester.tap(find.byKey(const Key('add_skill')));
        await tester.pump();

        // Verify skill management interaction
        expect(find.text('Add Skill'), findsOneWidget);
      });
    });
  });
} 