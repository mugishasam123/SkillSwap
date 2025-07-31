# SkillSwap Testing Suite

This directory contains comprehensive tests for the SkillSwap application, covering unit tests, widget tests, and integration tests.

## Test Structure

```
test/
├── auth_bloc_test.dart      # Unit tests for AuthBloc
├── widget_test.dart         # Widget tests for UI components
├── integration_test.dart    # Integration tests for complete flows
├── run_tests.dart          # Custom test runner
└── README.md              # This file
```

## Test Categories

### 1. Unit Tests (`auth_bloc_test.dart`)
Tests the business logic in the AuthBloc, including:
- Login flow testing
- Signup flow testing
- Google sign-in testing
- Error handling
- State transitions

### 2. Widget Tests (`widget_test.dart`)
Tests UI components and user interactions:
- Authentication forms
- Messaging interface
- Forum components
- Navigation flows
- Form validation

### 3. Integration Tests (`integration_test.dart`)
Tests complete user flows:
- Full authentication flow
- Skill discovery and matching
- Messaging and communication
- Forum participation
- Profile management

## Running Tests

### Prerequisites
```bash
# Install dependencies
flutter pub get

# Generate mock files
flutter pub run build_runner build
```

### Run All Tests
```bash
flutter test
```

### Run Specific Test Files
```bash
# Unit tests only
flutter test test/auth_bloc_test.dart

# Widget tests only
flutter test test/widget_test.dart

# Integration tests only
flutter test test/integration_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

### Custom Test Runner
```bash
dart test/run_tests.dart
```

## Test Results

When all tests pass, you should see output similar to:

```
🚀 Starting SkillSwap Test Suite...

📋 Test Categories:
  • Unit Tests: Testing AuthBloc business logic and state transitions
  • Widget Tests: Testing UI components and user interactions
  • Integration Tests: Testing complete user flows and feature integration

🧪 Running Unit Tests...
✅ Unit Tests passed

🧪 Running Widget Tests...
✅ Widget Tests passed

🧪 Running Integration Tests...
✅ Integration Tests passed

📊 Test Results Summary:
========================
Total Test Categories: 3
Passed: 3
Failed: 0
Success Rate: 100.0%

🎯 Final Status:
================
✅ ALL TESTS PASSED - Application is ready for deployment!
```

## Test Coverage

The testing suite covers:

### Core Functionalities
- ✅ Authentication (AuthBloc)
- ✅ User Interface Components
- ✅ Form Validation
- ✅ Navigation Flows
- ✅ Messaging Features
- ✅ Forum Features
- ✅ Profile Management
- ✅ Error Handling
- ✅ State Management
- ✅ User Interactions

### Test Scenarios
- **Authentication**: Login, signup, Google sign-in, logout
- **Form Validation**: Email, password, input validation
- **UI Interactions**: Button clicks, form submissions, navigation
- **Error Handling**: Network errors, validation errors, authentication failures
- **State Management**: BLoC state transitions, data flow
- **User Flows**: Complete end-to-end user journeys

## Adding New Tests

### For Unit Tests
1. Create test file in `test/` directory
2. Import necessary dependencies
3. Use `bloc_test` for BLoC testing
4. Use `mockito` for mocking dependencies
5. Follow naming convention: `feature_name_test.dart`

### For Widget Tests
1. Use `testWidgets` function
2. Test UI components in isolation
3. Simulate user interactions
4. Verify expected behaviors
5. Test error states and edge cases

### For Integration Tests
1. Test complete user flows
2. Verify component interactions
3. Test navigation between screens
4. Validate data persistence
5. Test error scenarios

## Best Practices

### Test Organization
- Group related tests using `group()`
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Keep tests independent and isolated

### Mocking
- Mock external dependencies
- Use realistic test data
- Verify mock interactions
- Clean up after tests

### Performance
- Keep tests fast and efficient
- Minimize resource usage
- Use appropriate test data size
- Avoid unnecessary setup/teardown

## Troubleshooting

### Common Issues

1. **Mock Generation Fails**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Test Dependencies Missing**
   ```bash
   flutter pub get
   ```

3. **Test Timeout**
   - Check for infinite loops
   - Verify async operations complete
   - Reduce test data size

4. **Flaky Tests**
   - Ensure tests are independent
   - Use proper setup/teardown
   - Avoid shared state between tests

### Debugging Tests
```bash
# Run with verbose output
flutter test --verbose

# Run specific test
flutter test test/auth_bloc_test.dart --verbose

# Debug mode
flutter test --debug
```

## Continuous Integration

The test suite is designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    flutter pub get
    flutter pub run build_runner build
    flutter test
```

## Documentation

For detailed testing documentation, see:
- `TESTING_DOCUMENTATION.md` - Comprehensive testing guide
- `test_report.json` - Generated test results (after running tests)

## Support

If you encounter issues with the test suite:
1. Check the troubleshooting section above
2. Review the test documentation
3. Ensure all dependencies are installed
4. Verify Flutter version compatibility 