#!/usr/bin/env bash
# npm-package-audit.sh - Tool for auditing npm package versions

# Create directories
mkdir -p versions
cd versions

# Download key versions
VERSIONS=(
  "0.2.56"
  "0.2.57"
  "0.2.54"
  "0.2.50"
  "0.2.48"
  "0.2.46"
  "0.2.45"
  "0.2.41"
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
