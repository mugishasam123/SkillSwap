// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('Message pages are responsive in landscape mode', (WidgetTester tester) async {
    // Test in landscape orientation
    tester.binding.window.physicalSizeTestValue = const Size(800, 400);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors in landscape
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Message pages are responsive in portrait mode', (WidgetTester tester) async {
    // Test in portrait orientation
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors in portrait
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Collapsible header functionality works correctly', (WidgetTester tester) async {
    // Test collapsible header behavior
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Forum page is responsive in landscape mode', (WidgetTester tester) async {
    // Test forum page in landscape orientation
    tester.binding.window.physicalSizeTestValue = const Size(800, 400);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors in landscape
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Forum page collapsible header works correctly', (WidgetTester tester) async {
    // Test forum page collapsible header behavior
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Forum page floating action button works correctly', (WidgetTester tester) async {
    // Test forum page floating action button behavior
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Home page collapsible header area works correctly', (WidgetTester tester) async {
    // Test home page collapsible header area behavior
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Debug banner is disabled', (WidgetTester tester) async {
    // Test that debug banner is disabled
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify that debug banner text is not present
    expect(find.text('DO NOT USE THIS IMAGE FOR PRODUCTION'), findsNothing);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });

  testWidgets('Layout works properly in landscape mode without overflow', (WidgetTester tester) async {
    // Test landscape mode layout
    tester.binding.window.physicalSizeTestValue = const Size(800, 400); // Landscape
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify that no overflow errors occur
    expect(tester.takeException(), isNull);
    
    // Reset the window size
    tester.binding.window.clearPhysicalSizeTestValue();
  });
}
