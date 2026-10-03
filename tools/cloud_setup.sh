#!/bin/bash
# Setup for Claude cloud sessions (Linux VM). Installs the Godot 4.7.1 Linux
# binary so the project can be imported and run headless - the same check
# that caught the axe/barrel bugs before they reached the phone.
# Never blocks the session: every step may fail quietly.
if ! command -v godot >/dev/null 2>&1; then
  cd /tmp && curl -sL -o godot.zip \
    https://github.com/godotengine/godot/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip \
    && unzip -q -o godot.zip \
    && install -m 755 Godot_v4.7.1-stable_linux.x86_64 /usr/local/bin/godot \
    || true
fi
command -v xvfb-run >/dev/null 2>&1 || (apt-get install -y -qq xvfb >/dev/null 2>&1 || true)
exit 0
