#!/bin/bash
# Cleanup script to remove build artifacts from git tracking
# Run this after updating .gitignore to untrack files that should be ignored

set -e

echo "🧹 Cleaning up git-tracked files that should be ignored..."
echo ""

cd "$(dirname "$0")/.."

# Remove Android build artifacts
echo "📱 Removing Android build artifacts..."
git rm -r --cached shell/android/app/.cxx/ 2>/dev/null || echo "  ✓ No .cxx files tracked"
git rm -r --cached shell/android/app/build/ 2>/dev/null || echo "  ✓ No build/ files tracked"
git rm -r --cached shell/android/.gradle/ 2>/dev/null || echo "  ✓ No .gradle/ files tracked"
git rm -r --cached shell/android/build/ 2>/dev/null || echo "  ✓ No android/build/ files tracked"

# Remove iOS build artifacts
echo "🍎 Removing iOS build artifacts..."
git rm -r --cached shell/ios/Pods/ 2>/dev/null || echo "  ✓ No Pods/ files tracked"
git rm -r --cached shell/ios/build/ 2>/dev/null || echo "  ✓ No ios/build/ files tracked"
git rm -r --cached shell/ios/DerivedData/ 2>/dev/null || echo "  ✓ No DerivedData/ files tracked"

# Remove generated files
echo "⚙️  Removing generated files..."
git rm --cached shell/lib/app_config.g.dart 2>/dev/null || echo "  ✓ No app_config.g.dart tracked"
git rm -r --cached shell/assets/generated/ 2>/dev/null || echo "  ✓ No generated/ assets tracked"
git rm --cached shell/flutter_launcher_icons.yaml 2>/dev/null || echo "  ✓ No flutter_launcher_icons.yaml tracked"
git rm --cached shell/flutter_native_splash.yaml 2>/dev/null || echo "  ✓ No flutter_native_splash.yaml tracked"

# Remove per-app config files
echo "🔐 Removing per-app config files..."
git rm --cached shell/android/key.properties 2>/dev/null || echo "  ✓ No key.properties tracked"
git rm --cached shell/android/app/google-services.json 2>/dev/null || echo "  ✓ No google-services.json tracked"
git rm --cached shell/ios/Runner/GoogleService-Info.plist 2>/dev/null || echo "  ✓ No GoogleService-Info.plist tracked"

# Remove build outputs
echo "📦 Removing build outputs..."
git rm -r --cached shell/builds/ 2>/dev/null || echo "  ✓ No builds/ directory tracked"
git rm --cached shell/*.aab 2>/dev/null || echo "  ✓ No .aab files tracked"
git rm --cached shell/*.ipa 2>/dev/null || echo "  ✓ No .ipa files tracked"
git rm --cached shell/*.apk 2>/dev/null || echo "  ✓ No .apk files tracked"

# Remove Flutter build artifacts
echo "🎯 Removing Flutter build artifacts..."
git rm -r --cached shell/build/ 2>/dev/null || echo "  ✓ No shell/build/ directory tracked"
git rm -r --cached core/build/ 2>/dev/null || echo "  ✓ No core/build/ directory tracked"

# Remove object files
echo "🔧 Removing object files..."
find shell -name "*.o" -exec git rm --cached {} \; 2>/dev/null || echo "  ✓ No .o files tracked"

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📝 Review changes with: git status"
echo "💾 Commit the cleanup with: git commit -m 'Remove build artifacts from git tracking'"
echo ""

