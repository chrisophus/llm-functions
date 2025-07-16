# Confluence Agent

An AI agent specialized in searching, retrieving, and managing Confluence content using advanced CQL (Confluence Query Language) queries.

## Features

- **Advanced Content Search**: Use CQL queries to find specific content across Confluence spaces
- **Page Retrieval**: Get specific pages by ID with optional child page inclusion
- **Flexible Filtering**: Search by creator, space, labels, dates, content type, and more
- **Result Management**: Control the number of results returned to avoid overwhelming responses
- **Formatted Output**: Returns clean, readable markdown content ready for analysis

## Common Use Cases

### Content Discovery
- Find documentation for specific projects or teams
- Locate content by specific authors or contributors
- Discover recently updated or created content
- Search for content with specific labels or tags

### Content Management
- Retrieve content from multiple spaces for comparison
- Find content that mentions specific users or topics
- Identify content that needs review or updating
- Locate outdated or orphaned content

### Team Collaboration
- Find all pages created by team members
- Discover content related to specific projects
- Track content changes and updates
- Identify frequently referenced documentation

## CQL Query Examples

### Basic Searches
- `type = page` - Find all pages
- `space = "DEV"` - Content in DEV space
- `creator = jsmith` - Content created by jsmith

### Advanced Searches
- `space = "DEV" AND type = page AND creator = jsmith ORDER BY created DESC`
- `(title ~ "API*" OR label = "api-docs") AND space IN ("DEV", "PROD")`
- `lastModified > startOfMonth() AND label = "needs-review"`

### Time-based Searches
- `created > startOfMonth()` - Content created this month
- `lastModified > startOfWeek()` - Recently modified content
- `created >= "2024-01-01"` - Content created after specific date

## Setup Requirements

1. Set environment variables:
   - `CONFLUENCE_API_TOKEN`: Your Confluence API token
   - `CONFLUENCE_BASE_URL`: Your Confluence base URL
   - `SECLAB`: Set to "true" if using proxy (optional)

2. Install required dependencies:
   ```bash
   pip install llama-index-readers-confluence
   ```

## Usage

The agent uses the `confluence.py` tool which supports:
- `page_id`: Retrieve specific page by ID
- `cql`: Advanced search using CQL queries
- `include_children`: Include child pages (page_id only)
- `max_num_results`: Limit number of results returned

## Conversation Starters

- "Find all pages in the DEV space created this month"
- "Search for API documentation across all spaces"
- "Show me content that mentions my username"
- "Find all pages with the 'needs-review' label"
- "Get the latest updates from the PROD space"
- "Search for content about authentication and security"
