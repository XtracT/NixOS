#!/usr/bin/env bash

set -euo pipefail

echo "🧼 Cleaning old system generations, keeping current and two previous..."

# Clean system generations except the latest 3 (current + 2 previous)
sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system

# Delete old store paths not referenced by any generation
sudo nix-collect-garbage -d

echo "🧼 Cleaning user profile generations..."

# Clean user profile generations (keep latest 3, like above)
nix-env --delete-generations +3

# Clean store again (in case user profile dropped more)
nix-collect-garbage -d

echo "✅ Done."
