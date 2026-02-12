#!/usr/bin/env bash
# Test script to verify qbot can start up in Nix environment

set -e

echo "=== QBot Startup Test ==="
echo ""

# Check if we're in a Nix environment
if ! command -v bundle &> /dev/null; then
    echo "Error: bundle command not found."
    echo "Please run this script from within the Nix development shell:"
    echo "  nix develop"
    echo "  ./test_startup.sh"
    exit 1
fi

echo "✓ Nix environment detected"

# Check configuration exists
if [ ! -f "config/global.yml" ]; then
    echo "Error: config/global.yml not found"
    echo "Please create a configuration file first."
    exit 1
fi

echo "✓ Configuration file exists"

# Check required directories
for dir in db var; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

echo "✓ Required directories exist"

# Test configuration parsing
echo ""
echo "Testing configuration parsing..."
ruby -e "require 'yaml'; YAML.load_file('config/global.yml'); puts '✓ Configuration parses correctly'"

echo ""
echo "=== Attempting to start qbot ==="
echo "Note: The bot will fail to connect to Discord with the test token."
echo "This is expected. We're only testing initialization."
echo ""

# Run the bot with a timeout to prevent hanging
# Use --no-console to avoid interactive mode
timeout 30 ./qbot --no-console 2>&1 | head -50 || {
    exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo ""
        echo "=== Test Result: TIMEOUT ==="
        echo "The bot ran for 30 seconds without crashing."
        echo "This suggests successful initialization up to Discord connection."
    else
        echo ""
        echo "=== Test Result: EARLY EXIT ==="
        echo "Exit code: $exit_code"
        echo "Check the output above for errors during initialization."
    fi
}

echo ""
echo "=== Startup Test Complete ==="
echo ""
echo "Expected behavior:"
echo "  - Configuration should parse successfully"
echo "  - Logo should be displayed"
echo "  - Database should initialize"
echo "  - Modules should load"
echo "  - Discord connection will fail (expected with test token)"
echo ""
echo "If you saw the logo and module loading messages, the test was successful!"
