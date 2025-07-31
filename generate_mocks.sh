#!/bin/bash

echo "🔧 Generating mock files for SkillSwap tests..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate mock files
echo "🔨 Generating mock files..."
flutter pub run build_runner build --delete-conflicting-outputs

# Check if generation was successful
if [ $? -eq 0 ]; then
    echo "✅ Mock files generated successfully!"
    echo "📁 Generated files:"
    find . -name "*.mocks.dart" -type f
else
    echo "❌ Failed to generate mock files. Please check the error messages above."
    exit 1
fi

echo "🎉 Mock generation complete! You can now run the tests." 