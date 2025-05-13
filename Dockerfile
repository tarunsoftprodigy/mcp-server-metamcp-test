FROM debian:12-slim

# 1. Prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg lsb-release && \
    rm -rf /var/lib/apt/lists/*

# 2. Node.js 20 via NodeSource distributions
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] \
      https://deb.nodesource.com/node_20.x \
      $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g npx && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

ENV NODE_ENV=production

# 3. Bind to Render’s dynamic port & 0.0.0.0
ENTRYPOINT ["sh","-c", \
  "npx -y @metamcp/mcp-server-metamcp@latest \
    --transport sse \
    --port $PORT \
    --host 0.0.0.0 \
    --metamcp-api-key $METAMCP_API_KEY"]
