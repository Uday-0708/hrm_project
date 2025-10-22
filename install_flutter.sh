#!/bin/bash

# Exit if any command fails
set -e

# Clone Flutter if not already cached
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
else
  echo "Flutter already cached"
fi

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Check Flutter version
flutter --version

# Pre-download web dependencies
flutter precache --web
