#!/usr/bin/env bash
set -e

# @describe Search Confluence using CQL (Confluence Query Language) to find pages, blog posts, and other content.
# Use this when you need to search internal documentation, team knowledge, or organizational content.

# @option --query! The CQL query to execute
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
    
    # Use provided arguments or fall back to environment variables
    local base_url="${argc_base_url:-$CONFLUENCE_BASE_URL}"
    local username="${argc_username:-$CONFLUENCE_USERNAME}"
    local api_token="${argc_api_token:-$CONFLUENCE_API_TOKEN}"
    
    # Encode the CQL query for URL
    local encoded_query=$(echo "$argc_query" | jq -sRr @uri)
    
    # Make the API request
    curl -fsSL \
        -u "$username:$api_token" \
        -H "Accept: application/json" \
        "$base_url/wiki/rest/api/content/search?cql=$encoded_query&limit=10&expand=body.storage,version" | \
        jq -r '
            .results[] | 
            "Title: " + .title + "\n" +
            "Type: " + .type + "\n" +
            "Space: " + .space.name + "\n" +
            "URL: " + ._links.webui + "\n" +
            "Page ID: " + (.id | tostring) + "\n" +
            "Last Modified: " + .version.when + "\n" +
            "Snippet: " + (.body.storage.value // "No content available" | .[0:200] + (if length > 200 then "..." else "" end)) + "\n" +
            "---"
        ' >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")" 