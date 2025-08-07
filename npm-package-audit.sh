#!/usr/bin/env bash
# npm-package-audit.sh - Tool for auditing npm package versions

# Create directories
mkdir -p versions
cd versions

# Download key versions
VERSIONS=(
  # Evolution from 1.0.0 to SDK in 1.0.67
  "1.0.0"   # Stable release baseline (1,596 downloads)
  "1.0.10"  # Early milestone (1,208 downloads)
  "1.0.24"  # First spike (2,866 downloads)
  "1.0.31"  # Growing adoption (5,247 downloads)
  "1.0.44"  # Steady growth (3,298 downloads)
  "1.0.51"  # Peak before jump (5,738 downloads)
  "1.0.64"  # MASSIVE JUMP (855,924 downloads)
  "1.0.65"  # Sustained high (855,230 downloads)
  "1.0.67"  # SDK release (1,018,483 downloads)
  
  # Original 0.2.x series for comparison
  "0.2.56"
  "0.2.57"
  "0.2.18"
)

for version in "${VERSIONS[@]}"; do
  echo "Processing version $version..."
  mkdir -p "$version"
  cd "$version"
  
  npm pack "@anthropic-ai/claude-code@$version"
  tar -xzf "anthropic-ai-claude-code-$version.tgz"
  
  cd ..
done

# Search for commands
echo "Searching for /doctor command..."
for version in "${VERSIONS[@]}"; do
  echo "In version $version:"
  grep -r --include="*.js" "doctor" "$version/package" | grep -v "node_modules" || echo "  Not found"
done

echo "Searching for /migrate-installer command..."
for version in "${VERSIONS[@]}"; do
  echo "In version $version:"
  grep -r --include="*.js" "migrate-installer" "$version/package" | grep -v "node_modules" || echo "  Not found"
done

echo "Analysis complete."
