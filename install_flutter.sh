#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Print each command before executing (for easier Netlify logs)
set -x

# Clone the Flutter SDK (stable channel)
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH for this session
export PATH="$PATH:`pwd`/flutter/bin"

# Check Flutter installation
flutter doctor

# Enable web support just to be sure
flutter config --enable-web

# Get dependencies
flutter pub get
