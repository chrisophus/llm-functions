# Confluence Search Agent

A specialized AI agent that searches Confluence documentation using CQL (Confluence Query Language) and intelligently fetches relevant content. This agent is designed to work seamlessly with the `aichat` CLI tool.

## Features

- **Intelligent Confluence Search**: Uses CQL to search internal documentation effectively
- **Two-Step Content Retrieval**: First searches for relevant pages, then fetches full content
- **Smart Page Selection**: Analyzes search results to identify the most relevant pages
- **Comprehensive Answers**: Combines information from multiple pages for complete responses
- **CQL Query Support**: Supports advanced Confluence Query Language for precise searches

## Search Tools Available

- **Confluence Search**: Search using CQL queries (returns titles, URLs, page IDs, and snippets)
- **Confluence Fetch**: Download full page content by page ID or URL

## Setup

### 1. Confluence Configuration
Set up the following environment variables for Confluence access:

```bash
export CONFLUENCE_BASE_URL="https://your-domain.atlassian.net"
export CONFLUENCE_USERNAME="your_email@domain.com"
export CONFLUENCE_API_TOKEN="your_api_token"
```

### 2. Get API Token
To use Confluence search:

1. **Get API Token**: 
   - Go to https://id.atlassian.com/manage-profile/security/api-tokens
   - Create a new API token

2. **Set Environment Variables**:
   ```bash
   export CONFLUENCE_BASE_URL="https://your-domain.atlassian.net"
   export CONFLUENCE_USERNAME="your_email@domain.com"
   export CONFLUENCE_API_TOKEN="your_api_token"
   ```

### 3. CQL Examples
```bash
# Search for pages containing "API documentation"
search_confluence --query 'text ~ "API documentation"'

# Search in specific space
search_confluence --query 'space = "TEAM" AND text ~ "deployment"'

# Search for recent pages
search_confluence --query 'lastmodified >= now("-7d") AND text ~ "meeting notes"'

# Search for specific content types
search_confluence --query 'type = "page" AND text ~ "onboarding"'

# Search pages by specific author
search_confluence --query 'creator = "username" AND text ~ "project"'
```

## Usage with Aichat

### Basic Usage
```bash
# Run the agent
aichat --agent agents/search

# Or with specific model
aichat --agent agents/search --model gpt-4
```

### Example Conversations

**User**: "Find our API documentation"

**Agent Behavior**: 
1. Searches Confluence for API documentation pages
2. Reviews results to identify most relevant pages
3. Fetches full content of relevant pages
4. Synthesizes information into comprehensive answer

**User**: "Search for recent meeting notes about the project"

**Agent Behavior**:
1. Uses CQL to search for recent meeting notes
2. Filters by date and project keywords
3. Fetches full content of meeting notes
4. Provides summary with links to original pages

**User**: "Find onboarding documentation for new employees"

**Agent Behavior**:
1. Searches for onboarding-related content
2. May search in HR or general spaces
3. Fetches multiple relevant pages
4. Combines information into complete onboarding guide

## Search Strategy

The agent uses a two-step approach for efficient and comprehensive searches:

1. **Initial Search**: Uses `search_confluence` to find relevant pages
   - Returns titles, URLs, page IDs, and content snippets
   - Helps identify which pages are most relevant

2. **Content Fetching**: Uses `fetch_confluence_page` to get full content
   - Downloads complete page content for the most relevant pages
   - Can fetch by page ID or URL
   - Provides comprehensive information for synthesis

## CQL Query Reference

### Basic Text Search
- `text ~ "keyword"` - Search for pages containing keyword
- `title ~ "title keyword"` - Search in page titles only

### Space Filtering
- `space = "SPACE_KEY"` - Search in specific space
- `space in ("SPACE1", "SPACE2")` - Search in multiple spaces

### Date Filtering
- `lastmodified >= now("-7d")` - Pages modified in last 7 days
- `created >= now("-30d")` - Pages created in last 30 days

### Content Type Filtering
- `type = "page"` - Only pages
- `type = "blogpost"` - Only blog posts
- `type in ("page", "blogpost")` - Both pages and blog posts

### Author Filtering
- `creator = "username"` - Pages by specific user
- `contributor = "username"` - Pages contributed to by user

### Combining Queries
- `space = "TEAM" AND text ~ "deployment"` - AND operator
- `text ~ "API" OR text ~ "documentation"` - OR operator
- `NOT space = "ARCHIVE"` - NOT operator

## Environment Variables Reference

| Variable | Description | Required |
|----------|-------------|----------|
| `CONFLUENCE_BASE_URL` | Confluence instance URL | Yes |
| `CONFLUENCE_USERNAME` | Confluence username/email | Yes |
| `CONFLUENCE_API_TOKEN` | Confluence API token | Yes |

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify your Confluence credentials and API token
2. **Permission Errors**: Ensure your account has access to the spaces you're searching
3. **Search Failures**: Check CQL syntax and ensure search terms exist in your Confluence

### Debug Mode
To see detailed tool execution, you can run with verbose output:
```bash
aichat --agent agents/search --verbose
```

## Contributing

To enhance the Confluence search capabilities:

1. Add new CQL query patterns to the agent instructions
2. Improve the search result analysis logic
3. Add support for additional Confluence content types

## License

This agent is part of the llm-functions framework and follows the same licensing terms. 