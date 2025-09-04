#!/bin/bash

# CreativeKit Pre-Build Validation Script
# Validates environment and dependencies before building

set -e

echo "🔧 Pre-build validation starting..."

# Check Node.js version
echo "📦 Checking Node.js version..."
if command -v node &> /dev/null; then
    node_version=$(node --version | cut -d'v' -f2)
    required_version="18.0.0"
    if [ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" = "$required_version" ]; then
        echo "✅ Node.js $node_version (>= $required_version required)"
    else
        echo "❌ Node.js $node_version found, but >= $required_version required"
        exit 1
    fi
else
    echo "❌ Node.js not found"
    exit 1
fi

# Check Rust version
echo "🦀 Checking Rust version..."
if command -v rustc &> /dev/null; then
    rust_version=$(rustc --version | cut -d' ' -f2)
    echo "✅ Rust $rust_version"
else
    echo "❌ Rust not found"
    exit 1
fi

# Check Tauri CLI
echo "🏗️  Checking Tauri CLI..."
if command -v cargo &> /dev/null && cargo tauri --version &> /dev/null; then
    tauri_version=$(cargo tauri --version | grep "tauri-cli" | cut -d' ' -f2)
    echo "✅ Tauri CLI $tauri_version"
else
    echo "❌ Tauri CLI not found"
    echo "Install with: cargo install tauri-cli"
    exit 1
fi

# Verify dependencies are installed
echo "📚 Checking dependencies..."
if [ ! -d "node_modules" ]; then
    echo "🔄 Installing frontend dependencies..."
    npm install
fi

cd src-tauri
if [ ! -d "target" ]; then
    echo "🔄 Checking Rust dependencies..."
    cargo check
fi
cd ..

# Check for required environment variables
echo "⚙️  Checking environment..."
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "⚠️  .env file not found, but .env.example exists"
    echo "Please create .env file based on .env.example"
fi

# Validate critical files exist
echo "📁 Validating project structure..."
required_files=(
    "package.json"
    "src-tauri/Cargo.toml"
    "src-tauri/src/main.rs"
    "src-tauri/tauri.conf.json"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Required file missing: $file"
        exit 1
    fi
done

echo "✅ Project structure validated"

# Check disk space (need at least 1GB for build)
echo "💾 Checking disk space..."
if command -v df &> /dev/null; then
    available_space=$(df . | tail -1 | awk '{print $4}')
    # Convert KB to GB (approximate)
    available_gb=$((available_space / 1024 / 1024))
    if [ "$available_gb" -lt 1 ]; then
        echo "⚠️  Low disk space: ${available_gb}GB available"
        echo "At least 1GB recommended for build"
    else
        echo "✅ Disk space: ${available_gb}GB available"
    fi
fi

# Verify no uncommitted changes in production builds
if [ "${BUILD_TYPE:-}" = "release" ]; then
    echo "🏷️  Production build - checking git status..."
    if [ -d ".git" ] && ! git diff --quiet; then
        echo "⚠️  Uncommitted changes detected in production build"
        echo "Consider committing changes first"
    fi
    
    # Check for clean working directory
    if [ -d ".git" ] && [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  Working directory not clean for production build"
    fi
fi

echo "✅ Pre-build validation completed successfully!"
echo "🚀 Ready to build CreativeKit"