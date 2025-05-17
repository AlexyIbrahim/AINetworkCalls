#!/usr/bin/env bash
# Usage: ./scripts/bump_version.sh [--dry-run] [--commit] [--tag]

DRY_RUN=false
DO_COMMIT=false
DO_TAG=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      ;;
    --commit)
      DO_COMMIT=true
      ;;
    --tag)
      DO_TAG=true
      ;;
  esac
done

# Directory paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BUMPVERSION_CFG="$PROJECT_ROOT/.bumpversion.cfg"
PACKAGE_SWIFT="$PROJECT_ROOT/Package.swift"
PODSPEC_FILE="$PROJECT_ROOT/AINetworkCalls.podspec"

# Read the current version from .bumpversion.cfg
current_version=$(grep "^current_version" "$BUMPVERSION_CFG" | cut -d'=' -f2 | tr -d ' ')
IFS='.' read -r major minor patch <<< "$current_version"
new_patch=$((patch + 1))
new_version="${major}.${minor}.${new_patch}"

commit_msg="Bump version: ${current_version} --> ${new_version}"
tag="${new_version}"

# Start a YAML document and output only YAML content
echo "---"
if [ "$DRY_RUN" = true ]; then
  echo "dry_run: true"
  echo "current_version: ${current_version}"
  echo "new_version: ${new_version}"
  if [ "$DO_COMMIT" = true ]; then
    echo "commit: ${commit_msg}"
  fi
  if [ "$DO_TAG" = true ]; then
    echo "tag: ${tag}"
  fi
  exit 0
fi

# Execute changes if not a dry run
echo "dry_run: false"
echo "current_version: ${current_version}"
echo "new_version: ${new_version}"

# Update .bumpversion.cfg
sed -i '' "s/^current_version *= *.*/current_version = ${new_version}/" "$BUMPVERSION_CFG"
echo "Updated .bumpversion.cfg to version ${new_version}"

# Update Package.swift
sed -i '' "s/\/\/ Package version: ${current_version}/\/\/ Package version: ${new_version}/" "$PACKAGE_SWIFT"
echo "Updated Package.swift to version ${new_version}"

# Update podspec file
if [ -f "$PODSPEC_FILE" ]; then
  sed -i '' "s/s.version          = '.*'/s.version          = '${new_version}'/" "$PODSPEC_FILE"
  echo "Updated AINetworkCalls.podspec to version ${new_version}"
fi

if [ "$DO_COMMIT" = true ]; then
  # Change to project root directory
  cd "$PROJECT_ROOT"
  
  git add "$BUMPVERSION_CFG" "$PACKAGE_SWIFT"
  
  # Also add podspec if it was updated
  if [ -f "$PODSPEC_FILE" ]; then
    git add "$PODSPEC_FILE"
  fi
  
  git commit -m "${commit_msg}"
  echo "commit: ${commit_msg}"
fi

if [ "$DO_TAG" = true ]; then
  # Ensure we're in the project root
  cd "$PROJECT_ROOT" 
  
  git tag "${tag}"
  echo "tag: ${tag}"
fi 