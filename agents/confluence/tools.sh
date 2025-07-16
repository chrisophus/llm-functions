#!/bin/bash

# Confluence Agent Tools
# This script provides convenient functions for common Confluence operations

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

# Function to search for recent content in a space
search_recent_in_space() {
    local space="$1"
    local days="${2:-7}"
    
    if [[ -z "$space" ]]; then
        echo "Usage: search_recent_in_space <space> [days]"
        return 1
    fi
    
    check_confluence_env
    
    local cql="space = \"$space\" AND lastModified > startOfDay(\"-${days}d\") ORDER BY lastModified DESC"
    python3 scripts/run-tool.py confluence "{\"cql\": \"$cql\", \"max_num_results\": 10}"
}

# Function to find content by creator
find_by_creator() {
    local creator="$1"
    local space="$2"
    
    if [[ -z "$creator" ]]; then
        echo "Usage: find_by_creator <creator> [space]"
        return 1
    fi
    
    check_confluence_env
    
    local cql="creator = \"$creator\""
    if [[ -n "$space" ]]; then
        cql="$cql AND space = \"$space\""
    fi
    cql="$cql ORDER BY created DESC"
    
    python3 scripts/run-tool.py confluence "{\"cql\": \"$cql\", \"max_num_results\": 15}"
}

# Function to search for content with specific labels
find_by_label() {
    local label="$1"
    local content_type="${2:-page}"
    
    if [[ -z "$label" ]]; then
        echo "Usage: find_by_label <label> [content_type]"
        return 1
    fi
    
    check_confluence_env
    
    local cql="label = \"$label\" AND type = \"$content_type\" ORDER BY lastModified DESC"
    python3 scripts/run-tool.py confluence "{\"cql\": \"$cql\", \"max_num_results\": 10}"
}

# Function to search for content mentioning a user
find_mentions() {
    local username="$1"
    local space="$2"
    
    if [[ -z "$username" ]]; then
        echo "Usage: find_mentions <username> [space]"
        return 1
    fi
    
    check_confluence_env
    
    local cql="mention = \"$username\""
    if [[ -n "$space" ]]; then
        cql="$cql AND space = \"$space\""
    fi
    cql="$cql ORDER BY lastModified DESC"
    
    python3 scripts/run-tool.py confluence "{\"cql\": \"$cql\", \"max_num_results\": 10}"
}

# Function to search for content by title pattern
search_by_title() {
    local title_pattern="$1"
    local space="$2"
    
    if [[ -z "$title_pattern" ]]; then
        echo "Usage: search_by_title <title_pattern> [space]"
        return 1
    fi
    
    check_confluence_env
    
    local cql="title ~ \"$title_pattern\""
    if [[ -n "$space" ]]; then
        cql="$cql AND space = \"$space\""
    fi
    cql="$cql ORDER BY lastModified DESC"
    
    python3 scripts/run-tool.py confluence "{\"cql\": \"$cql\", \"max_num_results\": 10}"
}

# Function to get a specific page and its children
get_page_with_children() {
    local page_id="$1"
    local max_results="${2:-20}"
    
    if [[ -z "$page_id" ]]; then
        echo "Usage: get_page_with_children <page_id> [max_results]"
        return 1
    fi
    
    check_confluence_env
    
    python3 scripts/run-tool.py confluence "{\"page_id\": \"$page_id\", \"include_children\": true, \"max_num_results\": $max_results}"
}

# Function to find content that needs review
find_needs_review() {
    local space="$1"
    
    check_confluence_env
    
    local cql="label = \"needs-review\""
    if [[ -n "$space" ]]; then
        cql="$cql AND space = \"$space\""
    fi
    cql="$cql ORDER BY lastModified DESC"
    
    python3 scripts/run-tool.py confluence "{\"cql\": \"$cql\", \"max_num_results\": 15}"
}

# Function to search across multiple spaces
search_multi_space() {
    local query="$1"
    shift
    local spaces=("$@")
    
    if [[ -z "$query" ]] || [[ ${#spaces[@]} -eq 0 ]]; then
        echo "Usage: search_multi_space <query> <space1> <space2> ..."
        return 1
    fi
    
    check_confluence_env
    
    # Build space IN clause
    local space_clause="space IN ("
    for i in "${!spaces[@]}"; do
        if [[ $i -gt 0 ]]; then
            space_clause+=", "
        fi
        space_clause+="\"${spaces[$i]}\""
    done
    space_clause+=")"
    
    local cql="text ~ \"$query\" AND $space_clause ORDER BY lastModified DESC"
    python3 scripts/run-tool.py confluence "{\"cql\": \"$cql\", \"max_num_results\": 20}"
}

# Help function
show_help() {
    echo "Confluence Agent Tools"
    echo "====================="
    echo
    echo "Available functions:"
    echo "  search_recent_in_space <space> [days]         - Find recent content in space"
    echo "  find_by_creator <creator> [space]             - Find content by creator"
    echo "  find_by_label <label> [content_type]          - Find content with specific label"
    echo "  find_mentions <username> [space]              - Find content mentioning user"
    echo "  search_by_title <title_pattern> [space]       - Search by title pattern"
    echo "  get_page_with_children <page_id> [max_results] - Get page and its children"
    echo "  find_needs_review [space]                     - Find content needing review"
    echo "  search_multi_space <query> <space1> <space2> - Search across multiple spaces"
    echo
    echo "Examples:"
    echo "  search_recent_in_space \"DEV\" 14"
    echo "  find_by_creator \"jsmith\" \"PROD\""
    echo "  find_by_label \"api-docs\""
    echo "  search_by_title \"API*\" \"DEV\""
    echo "  get_page_with_children \"123456\" 10"
    echo "  search_multi_space \"authentication\" \"DEV\" \"PROD\" \"SEC\""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        search_recent_in_space)
            search_recent_in_space "$2" "$3"
            ;;
        find_by_creator)
            find_by_creator "$2" "$3"
            ;;
        find_by_label)
            find_by_label "$2" "$3"
            ;;
        find_mentions)
            find_mentions "$2" "$3"
            ;;
        search_by_title)
            search_by_title "$2" "$3"
            ;;
        get_page_with_children)
            get_page_with_children "$2" "$3"
            ;;
        find_needs_review)
            find_needs_review "$2"
            ;;
        search_multi_space)
            shift
            search_multi_space "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
fi
