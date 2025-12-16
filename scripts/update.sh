# scripts/update.sh
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "Fetching latest manifest..."
curl -fsSL https://proton.me/download/pass-cli/versions.json -o versions.json.new

VERSION_NEW=$(jq -r '.passCliVersions.version' versions.json.new)

if [[ -f versions.json ]]; then
  VERSION_CURRENT=$(jq -r '.passCliVersions.version' versions.json)
else
  VERSION_CURRENT=""
fi

if [[ "$VERSION_NEW" == "$VERSION_CURRENT" ]]; then
    echo "Already up to date: $VERSION_NEW"
    rm versions.json.new
    exit 0
fi

echo "Updating to new version $VERSION_NEW"

mv versions.json.new versions.json

echo "Updated versions.json to $VERSION_NEW"
echo ""
echo "The flake now automatically uses the new URLs and hashes."
echo "Test with: nix build .#proton-pass-cli --no-link --print-build-logs"
echo "Then commit: git add versions.json && git commit -m 'proton-pass-cli: update to $VERSION_NEW'"
