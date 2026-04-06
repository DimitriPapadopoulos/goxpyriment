#!/bin/bash
# Raspberry Pi fullscreen workaround.
# SDL3 exclusive fullscreen does not render correctly under the Pi's V3D/KMS
# stack; forcing software rendering + Wayland fixes the issue.
#
# Usage: ./run_pi.sh <example/main.go> [flags...]
# Example: ./run_pi.sh Number-Change-Detection/main.go -exp preliminary
SDL_RENDER_DRIVER=software SDL_VIDEODRIVER=wayland go run "$@"
