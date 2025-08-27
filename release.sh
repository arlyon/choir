#!/bin/bash

# Flutter App Release Script with Auto-Upload
# Run this script to build and upload to Play Store in one command

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Flutter Release Build & Upload Process${NC}"

# Get current version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
echo -e "${GREEN}📱 Building and uploading version: $VERSION${NC}"

# Build the app bundle
echo -e "${BLUE}🔨 Building app bundle...${NC}"
flutter build appbundle --dart-define-from-file=env-prod.json

# Check if build was successful
if [ ! -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo -e "${RED}❌ Build failed - app-release.aab not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed successfully${NC}"

# Upload to Play Store
echo -e "${BLUE}📤 Uploading to Play Store...${NC}"
cd android
fastlane deploy

echo -e "${GREEN}🎉 Release completed successfully!${NC}"
echo -e "${GREEN}Version $VERSION has been uploaded to Play Store${NC}"