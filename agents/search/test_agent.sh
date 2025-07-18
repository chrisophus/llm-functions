#!/usr/bin/env bash
set -e

# Test script for the Search Agent
# This script demonstrates how to use the search agent with aichat

echo "=== Confluence Search Agent Test Script ==="
echo "This script will test the Confluence search agent with aichat"
echo ""

# Check if aichat is installed
if ! command -v aichat &> /dev/null; then
    echo "Error: aichat is not installed. Please install it first:"
    echo "  cargo install aichat"
    exit 1
fi

echo "✓ aichat is installed"
echo ""

# Test basic agent functionality
echo "Testing basic agent functionality..."
echo "Running: aichat --agent agents/search --model gpt-4"
echo ""

# Note: This would normally start an interactive session
# For testing purposes, we'll just show the command
echo "To start the search agent, run:"
echo "  aichat --agent agents/search --model gpt-4"
echo ""
echo "Example questions to try:"
echo "  - Find our API documentation"
echo "  - Search for recent meeting notes about the project"
echo "  - Find onboarding documentation for new employees"
echo "  - Look for deployment procedures"
echo "  - Search for troubleshooting guides"
echo ""

# Check if environment variables are set for Confluence access
echo "=== Confluence Environment Variables Check ==="
if [[ -n "$CONFLUENCE_BASE_URL" && -n "$CONFLUENCE_USERNAME" && -n "$CONFLUENCE_API_TOKEN" ]]; then
    echo "✓ Confluence credentials are set"
else
    echo "⚠ Confluence credentials are not set (Confluence search will not work)"
fi

echo ""
echo "=== Setup Instructions ==="
echo "To enable Confluence search, set the following environment variables:"
echo ""
echo "export CONFLUENCE_BASE_URL=\"https://your-domain.atlassian.net\""
echo "export CONFLUENCE_USERNAME=\"your_email@domain.com\""
echo "export CONFLUENCE_API_TOKEN=\"your_api_token\""
echo ""
echo "=== Usage Examples ==="
echo ""
echo "1. Basic usage:"
echo "   aichat --agent agents/search"
echo ""
echo "2. With specific model:"
echo "   aichat --agent agents/search --model gpt-4"
echo ""
echo "3. With verbose output:"
echo "   aichat --agent agents/search --verbose"
echo ""
echo "4. With custom username:"
echo "   aichat --agent agents/search --username \"Your Name\""
echo ""
echo "The agent will search your Confluence documentation and fetch relevant content!" 