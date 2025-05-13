FROM ghcr.io/astral-sh/uv:debian

# Install Node.js & npx
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . . 
RUN npm run build

ENV NODE_ENV=production

# No hard-coded EXPOSE needed; Render will detect $PORT automatically
# EXPOSE 3000  <- remove this

# Start the MCP server binding to Render’s dynamic port
ENTRYPOINT ["sh", "-c", \
  "npx -y @metamcp/mcp-server-metamcp@latest \
     --transport sse \
     --port $PORT \
     --metamcp-api-key $METAMCP_API_KEY \
     --host 0.0.0.0"]
