FROM ghcr.io/astral-sh/uv:debian

# 1. Install prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      lsb-release && \
    rm -rf /var/lib/apt/lists/*

# 2. Setup NodeSource & install Node.js + npx
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
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

# No hard-coded EXPOSE – will bind to $PORT at runtime
ENTRYPOINT ["sh", "-c", \
  "npx -y @metamcp/mcp-server-metamcp@latest \
     --transport sse \
     --port $PORT \
     --metamcp-api-key $METAMCP_API_KEY \
     --host 0.0.0.0"]
