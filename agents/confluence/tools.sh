#!/bin/bash

# Check if required environment variables are set
check_confluence_env() {
    if [[ -z "$CONFLUENCE_API_TOKEN" ]]; then
        echo "Error: CONFLUENCE_API_TOKEN environment variable not set"
        exit 1
    fi
    if [[ -z "$CONFLUENCE_BASE_URL" ]]; then
        echo "Error: CONFLUENCE_BASE_URL environment variable not set"
        exit 1
    fi
}

# @cmd Nothing useful here, just a placeholder
check_stuff() {
    local query="$1"
    local max_results="${2:-20}"
    
    if [[ -z "$query" ]]; then
        echo "Usage: search_confluence <query> [max_results]"
        echo
        echo "Query can be:"
        echo "  - Plain text search"
        echo "  - CQL (Confluence Query Language)"
        echo "  - JSON parameters for advanced search"
        echo
        echo "Examples:"
        echo "  search_confluence \"API documentation\""
        echo "  search_confluence 'space = \"DEV\" AND lastModified > startOfDay(\"-7d\")'"
        echo "  search_confluence '{\"cql\": \"creator = \\\"jsmith\\\"\", \"max_num_results\": 10}'"
        return 1
    fi
    
    check_confluence_env
    
    # Check if query is JSON
    if [[ "$query" =~ ^[[:space:]]*\{ ]]; then
        # Query is JSON, pass it directly
        python3 scripts/run-tool.py confluence "$query"
    elif [[ "$query" =~ (space|creator|label|mention|title|type|lastModified|created)[[:space:]]*[=~] ]]; then
        # Query looks like CQL, wrap it in JSON
        local json_query="{\"cql\": \"$query\", \"max_num_results\": $max_results}"
        python3 scripts/run-tool.py confluence "$json_query"
    else
        # Plain text search
        local json_query="{\"text\": \"$query\", \"max_num_results\": $max_results}"
        python3 scripts/run-tool.py confluence "$json_query"
    fi
}

eval "$(argc --argc-eval "$0" "$@")"