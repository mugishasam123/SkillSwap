// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SkillSwap basic widget test', (WidgetTester tester) async {
    // Build a simple test widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('SkillSwap')),
          body: const Center(
            child: Text('Welcome to SkillSwap'),
          ),
        ),
      ),
    );

    // Verify our test widget is working
    expect(find.text('SkillSwap'), findsOneWidget);
    expect(find.text('Welcome to SkillSwap'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('Form validation simulation', (WidgetTester tester) async {
    String? validationError;
    
    // Simulate form validation logic
    String validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      if (!value.contains('@')) {
        return 'Invalid email format';
      }
      return '';
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final result = validateEmail(value);
                  validationError = result.isEmpty ? null : result;
                  return validationError;
                },
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );

    // Test validation logic
    expect(validateEmail(''), 'Email is required');
    expect(validateEmail('invalid'), 'Invalid email format');
    expect(validateEmail('test@example.com'), '');
    
    // Verify UI elements exist
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}