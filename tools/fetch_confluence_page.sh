#!/usr/bin/env bash
set -e

# @describe Fetch a specific Confluence page by its ID or URL to get the full content.
# Use this when you need to get the complete content of a specific page after searching.

# @option --page-id The Confluence page ID
# @option --page-url The full Confluence page URL
# @option --base-url The Confluence base URL (e.g., https://your-domain.atlassian.net)
# @option --username The Confluence username or email
# @option --api-token The Confluence API token

# @env CONFLUENCE_BASE_URL! The Confluence base URL
# @env CONFLUENCE_USERNAME! The Confluence username or email
# @env CONFLUENCE_API_TOKEN! The Confluence API token
# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Validate required environment variables or arguments
    if [[ -z "$CONFLUENCE_BASE_URL" && -z "$argc_base_url" ]]; then
        echo "Error: CONFLUENCE_BASE_URL environment variable or --base-url is required" >&2
        exit 1
    fi
    
    if [[ -z "$CONFLUENCE_USERNAME" && -z "$argc_username" ]]; then
        echo "Error: CONFLUENCE_USERNAME environment variable or --username is required" >&2
        exit 1
    fi
    
    if [[ -z "$CONFLUENCE_API_TOKEN" && -z "$argc_api_token" ]]; then
        echo "Error: CONFLUENCE_API_TOKEN environment variable or --api-token is required" >&2
        exit 1
    fi
    
    if [[ -z "$argc_page_id" && -z "$argc_page_url" ]]; then
        echo "Error: Either --page-id or --page-url is required" >&2
        exit 1
    fi
    
    # Use provided arguments or fall back to environment variables
    local base_url="${argc_base_url:-$CONFLUENCE_BASE_URL}"
    local username="${argc_username:-$CONFLUENCE_USERNAME}"
    local api_token="${argc_api_token:-$CONFLUENCE_API_TOKEN}"
    
    local page_id="$argc_page_id"
    
    # If page URL is provided, extract the page ID from it
    if [[ -n "$argc_page_url" ]]; then
        # Extract page ID from URL like: https://domain.atlassian.net/wiki/spaces/SPACE/pages/12345/Page+Title
        page_id=$(echo "$argc_page_url" | grep -o '/pages/[0-9]*/' | grep -o '[0-9]*')
        if [[ -z "$page_id" ]]; then
            echo "Error: Could not extract page ID from URL: $argc_page_url" >&2
            exit 1
        fi
    fi
    
    # Make the API request to get the full page content
    curl -fsSL \
        -u "$username:$api_token" \
        -H "Accept: application/json" \
        "$base_url/wiki/rest/api/content/$page_id?expand=body.storage,version,space" | \
        jq -r '
            "Title: " + .title + "\n" +
            "Type: " + .type + "\n" +
            "Space: " + .space.name + "\n" +
            "URL: " + ._links.webui + "\n" +
            "Last Modified: " + .version.when + "\n" +
            "Content:\n" + (.body.storage.value // "No content available") + "\n" +
            "---"
        ' >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")" 