# Authenticated Snippify connection

Configure a Streamable HTTP MCP connection to the Snippify `/mcp` endpoint and send a current access token through the host's bearer-token environment-variable facility.

Agent login tokens record `suggested_by: agent`; user/client login tokens record `suggested_by: client`. Use an access token, never a refresh token. Missing authentication still permits public tools but authenticated owner and suggestion tools will fail.

Never commit or print the token. Keep it in the agent host's environment or secret facility and refresh it through the Snippify authentication API when expired.
