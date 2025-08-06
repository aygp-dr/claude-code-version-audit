#!/usr/bin/env bash
# fetch-version-metadata.sh - Fetch release dates and metadata for Claude Code versions

echo "Fetching version metadata for @anthropic-ai/claude-code..."

# Get all versions with their publish times
echo "Getting version release dates..."
npm view @anthropic-ai/claude-code time --json > version-metadata.json

# Extract specific versions we're analyzing
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

echo "Version Release Timeline:"
echo "========================"
for version in "${VERSIONS[@]}"; do
  release_date=$(cat version-metadata.json | jq -r ".\"$version\"" 2>/dev/null || echo "Not found")
  if [ "$release_date" != "Not found" ] && [ "$release_date" != "null" ]; then
    echo "v$version: $release_date"
  fi
done

# Get current download stats
echo -e "\nCurrent Download Statistics:"
echo "============================"
curl -s https://api.npmjs.org/downloads/point/last-week/@anthropic-ai/claude-code | jq '.'
echo ""
curl -s https://api.npmjs.org/downloads/point/last-month/@anthropic-ai/claude-code | jq '.'

# Get latest version info
echo -e "\nLatest Version Info:"
echo "==================="
npm view @anthropic-ai/claude-code version

echo -e "\nNote: For historical per-version download stats, visit:"
echo "https://npm-stat.com/charts.html?package=%40anthropic-ai%2Fclaude-code&from=2024-11-12"