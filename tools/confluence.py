import os
from typing import List, Optional

def run(
    page_id: Optional[str] = None,
    cql: Optional[str] = None,
    include_children: bool = False,
    max_num_results: Optional[int] = 5,
):
    """Fetch Confluence page content using either page ID or CQL query and return it as markdown for aichat.
    
    Advanced searching using CQL (Confluence Query Language):
    CQL allows you to use structured queries to search for content in Confluence.
    A simple query consists of a field, operator, and value. For example:
    - space = "DEV" (find all content in the DEV space)
    - type = page AND creator = jsmith (find all pages created by jsmith)
    - title ~ "Advanced*" (find content with titles starting with "Advanced")
    
    Common CQL operators:
    - = (equals): exact match
    - != (not equals): does not match
    - ~ (contains): fuzzy text match with wildcards
    - !~ (does not contain): does not match text
    - IN (value1, value2): matches any of the values
    - AND, OR, NOT: combine clauses
    - ORDER BY field [ASC|DESC]: sort results
    
    Common CQL fields:
    - space: space key (e.g., "DEV", "PROD")
    - type: content type (page, blogpost, attachment)
    - title: page title
    - creator: username of creator
    - contributor: username of contributor
    - created: creation date
    - lastModified: last modification date
    - label: content labels
    - mention: mentioned users
    
    CQL Examples:
    - 'space = "DEV" AND type = page' - All pages in DEV space
    - 'creator = jsmith ORDER BY created DESC' - All content by jsmith, newest first
    - 'title ~ "API*" AND space IN ("DEV", "PROD")' - Pages with titles starting with "API" in DEV or PROD spaces
    - 'lastModified > startOfMonth() AND label = "needs_review"' - Recently modified content with needs_review label
    
    Args:
        page_id: The Confluence page ID to fetch (mutually exclusive with cql)
        cql: CQL query string to search for content (mutually exclusive with page_id)
        include_children: Whether to include child pages in the response (only applies to page_id)
        max_num_results: Maximum number of results to return. If None, return all results.
    """
    try:
        from llama_index.readers.confluence import ConfluenceReader
    except ImportError:
        return "Error: llama_index.readers.confluence module not found. Please install it with: pip install llama-index-readers-confluence"
    
    # Validate input parameters
    if not page_id and not cql:
        return "Error: Either 'page_id' or 'cql' parameter must be provided"
    
    if page_id and cql:
        return "Error: Cannot use both 'page_id' and 'cql' parameters simultaneously. Choose one."
    
    # Configure connection based on environment
    confluence_kwargs = {}
    if os.getenv("SECLAB") == "true":
        confluence_kwargs = {
            "verify_ssl": False,
            "proxies": {
                "http": "http://svc-proxy.cls.eng.netapp.com:3128",
                "https": "http://svc-proxy.cls.eng.netapp.com:3128"
            }
        }

    # Check for required environment variables
    api_token = os.getenv("CONFLUENCE_API_TOKEN")
    base_url = os.getenv("CONFLUENCE_BASE_URL")
    
    if not api_token:
        return "Error: CONFLUENCE_API_TOKEN environment variable not set"
    if not base_url:
        return "Error: CONFLUENCE_BASE_URL environment variable not set"

    try:
        reader = ConfluenceReader(
            api_token=api_token,
            client_args=confluence_kwargs,
            base_url=base_url
        )

        # Load content based on parameter type
        if page_id:
            # Load specific page by ID
            documents = reader.load_data(
                page_ids=[page_id], 
                include_children=include_children,
                max_num_results=max_num_results
            )
            if not documents:
                return f"Error: No content found for Confluence page ID: {page_id}"
        else:
            # Load content using CQL query
            documents = reader.load_data(
                cql=cql,
                max_num_results=max_num_results
            )
            if not documents:
                return f"Error: No content found for CQL query: {cql}"

        # Format the content for aichat
        output_parts = []
        
        for doc in documents:
            # Access metadata using extra_info (as shown in ConfluenceReader documentation)
            page_id_meta = doc.extra_info.get('page_id', 'unknown')
            title = doc.extra_info.get('title', 'Untitled')
            space_name = doc.extra_info.get('space_name', 'Unknown Space')
            url = doc.extra_info.get('url', '')
            
            # Create a formatted section for each page
            section = f"# {title}\n\n"
            section += f"**Page ID:** {page_id_meta}\n"
            section += f"**Space:** {space_name}\n"
            if url:
                section += f"**URL:** {url}\n"
            section += f"\n---\n\n{doc.text}\n"
            
            output_parts.append(section)

        return "\n\n".join(output_parts)

    except Exception as e:
        return f"Error fetching Confluence content: {str(e)}"

