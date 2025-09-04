#!/bin/bash

# CreativeKit Post-Build Script
# Runs security scans, generates checksums, and validates build artifacts

set -e

echo "🎉 Post-build processing starting..."

# Find build output directory
if [ -d "src-tauri/target/release/bundle" ]; then
    BUILD_DIR="src-tauri/target/release/bundle"
elif [ -d "src-tauri/target/debug/bundle" ]; then
    BUILD_DIR="src-tauri/target/debug/bundle"
else
    echo "❌ No build artifacts found"
    exit 1
fi

echo "📁 Build artifacts found in: $BUILD_DIR"

# Generate checksums for all build artifacts
echo "🔐 Generating checksums..."
cd "$BUILD_DIR"
find . -type f -name "*.exe" -o -name "*.msi" -o -name "*.deb" -o -name "*.dmg" -o -name "*.app" | while read -r file; do
    if command -v sha256sum &> /dev/null; then
        sha256sum "$file" > "$file.sha256"
        echo "✅ Generated checksum for $file"
    elif command -v shasum &> /dev/null; then
        shasum -a 256 "$file" > "$file.sha256"
        echo "✅ Generated checksum for $file"
    else
        echo "⚠️  No checksum tool available"
    fi
done
cd - > /dev/null

# Check binary sizes
echo "📏 Analyzing build sizes..."
find "$BUILD_DIR" -type f \( -name "*.exe" -o -name "*.msi" -o -name "*.deb" -o -name "*.dmg" \) | while read -r file; do
    size=$(ls -lh "$file" | awk '{print $5}')
    echo "📦 $file: $size"
    
    # Warn if binary is unusually large (>100MB)
    size_bytes=$(ls -l "$file" | awk '{print $5}')
    if [ "$size_bytes" -gt 104857600 ]; then
        echo "⚠️  Large binary size: $file ($size)"
        echo "Consider optimizing build size"
    fi
done

# Basic security scan - check for common issues
echo "🔍 Running basic security scan..."

# Check for hardcoded secrets in binaries (basic check)
find "$BUILD_DIR" -type f \( -name "*.exe" -o -name "CreativeKit" -o -name "*.app" \) | while read -r binary; do
    if command -v strings &> /dev/null; then
        if strings "$binary" | grep -i "password\|secret\|key" > /dev/null 2>&1; then
            echo "⚠️  Potential sensitive strings found in $binary"
            echo "Please review manually"
        fi
    fi
done

# Validate that required files are present in bundle
echo "📋 Validating bundle contents..."
required_in_bundle=false

if [ -d "$BUILD_DIR/msi" ]; then
    required_in_bundle=true
    echo "✅ Windows MSI installer found"
fi

if [ -d "$BUILD_DIR/deb" ]; then
    required_in_bundle=true
    echo "✅ Linux DEB package found"
fi

if [ -d "$BUILD_DIR/dmg" ] || [ -d "$BUILD_DIR/macos" ]; then
    required_in_bundle=true
    echo "✅ macOS bundle found"
fi

if [ "$required_in_bundle" = false ]; then
    echo "❌ No platform-specific installers found"
    exit 1
fi

# Generate build report
echo "📊 Generating build report..."
BUILD_REPORT="build-report-$(date +%Y%m%d-%H%M%S).txt"

{
    echo "CreativeKit Build Report"
    echo "======================="
    echo "Build Date: $(date)"
    echo "Build User: $(whoami)"
    echo "Git Commit: $(git rev-parse HEAD 2>/dev/null || echo 'N/A')"
    echo "Git Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
    echo ""
    echo "Build Artifacts:"
    find "$BUILD_DIR" -type f -name "*.exe" -o -name "*.msi" -o -name "*.deb" -o -name "*.dmg" | while read -r file; do
        echo "- $file ($(ls -lh "$file" | awk '{print $5}'))"
    done
    echo ""
    echo "Checksums:"
    find "$BUILD_DIR" -name "*.sha256" -exec cat {} \;
} > "$BUILD_REPORT"

echo "✅ Build report saved to: $BUILD_REPORT"

# Upload to artifacts directory if it exists
if [ -d "artifacts" ]; then
    cp "$BUILD_REPORT" "artifacts/"
    echo "📁 Build report copied to artifacts directory"
fi

# Log successful build
echo "$(date): Build completed successfully by $(whoami)" >> .build.log

# Check if this is a release build and create release notes template
if [ "${BUILD_TYPE:-}" = "release" ]; then
    echo "🏷️  Release build detected - creating release notes template..."
    
    RELEASE_NOTES="release-notes-$(date +%Y%m%d).md"
    {
        echo "# CreativeKit Release - $(date +%Y-%m-%d)"
        echo ""
        echo "## What's New"
        echo "- [ ] Feature 1"
        echo "- [ ] Feature 2"
        echo ""
        echo "## Bug Fixes"
        echo "- [ ] Fix 1"
        echo "- [ ] Fix 2"
        echo ""
        echo "## Technical Changes"
        echo "- Build Date: $(date)"
        echo "- Commit: $(git rev-parse HEAD 2>/dev/null || echo 'N/A')"
        echo ""
        echo "## Download Links"
        find "$BUILD_DIR" -type f -name "*.exe" -o -name "*.msi" -o -name "*.deb" -o -name "*.dmg" | while read -r file; do
            filename=$(basename "$file")
            echo "- [$filename](./$(basename "$BUILD_DIR")/$filename)"
        done
    } > "$RELEASE_NOTES"
    
    echo "📝 Release notes template created: $RELEASE_NOTES"
fi

echo "✅ Post-build processing completed successfully!"
echo "🎊 CreativeKit build ready for distribution"