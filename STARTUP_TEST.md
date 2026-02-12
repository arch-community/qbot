# QBot Startup Test Guide

This document describes how to test that qbot can start up properly.

## Prerequisites

- Nix with flakes support
- Access to qbot repository

## Quick Start

The easiest way to test the bot startup is using the provided test script:

```bash
# Enter the Nix development environment
nix develop

# Run the automated test
./test_startup.sh
```

The script will check prerequisites, validate the configuration, and attempt to start the bot.

## Configuration

A minimal configuration file should be created at `config/global.yml` with:
- Placeholder token (e.g., `test_token_placeholder`)
- Test client ID (e.g., `123456789`)
- All default modules enabled
- SQLite database configuration

Example configuration is available in `config/global.yml.example`.

## Directory Setup

The following directories are needed:
- `db/` - For SQLite database files (preserved in git with `.gitkeep`)
- `var/` - For state directory (preserved in git with `.gitkeep`)

These directories are tracked in git but their contents are gitignored.

## Manual Testing

### Option 1: Using Nix Development Shell

```bash
# Enter the Nix development environment
nix develop

# Run the bot with no-console flag to avoid interactive mode
./qbot --no-console
```

The bot will:
1. Parse the configuration file
2. Initialize the logger
3. Set up the database connection
4. Load all modules
5. Attempt to connect to Discord (will fail with invalid token, which is expected)

### Option 2: Direct Execution

```bash
# From within the Nix shell
bundle exec ruby qbot
```

## Expected Behavior

The bot should:
- ✓ Successfully parse `config/global.yml`
- ✓ Initialize logger and print the logo
- ✓ Create database schema if it doesn't exist
- ✓ Load all 16 configured modules
- ✗ Fail to connect to Discord (expected with test token)

The connection failure is expected and acceptable for this test.

## Validating Success

Success criteria:
1. No configuration parsing errors
2. No module loading errors
3. Database initializes correctly
4. Bot reaches the Discord connection stage

The test token will cause a connection error like:
```
Error: Invalid authentication token
```

This is expected and indicates the bot successfully initialized up to the connection phase.

## Files in This Repository

- `config/global.yml.example` - Example configuration (committed to git)
- `config/global.yml` - Your actual configuration (gitignored, create from example)
- `db/.gitkeep` - Preserves db/ directory in git
- `var/.gitkeep` - Preserves var/ directory in git
- `test_startup.sh` - Automated startup test script
- `STARTUP_TEST.md` - This documentation

## Cleanup

To clean up test artifacts:
```bash
rm -rf db/*.sqlite3 var/*
```

Note: Keep `config/global.yml` for future testing but do not commit it with real credentials.
