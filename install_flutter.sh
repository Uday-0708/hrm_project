#!/bin/bash
set -e
set -x

# Clone Flutter only if it doesn't exist
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
else
  echo "Flutter SDK already exists, skipping clone"
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Check Flutter installation
flutter doctor

# Enable web support
flutter config --enable-web

# Get dependencies
flutter pub get
