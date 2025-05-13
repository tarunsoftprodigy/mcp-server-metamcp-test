# 1. Base image with Node.js 20 (slim)
FROM node:20-slim

# 2. Install dependencies & build
WORKDIR /app
COPY package*.json ./
RUN npm ci                                 # deterministic installs citeturn3search3
COPY . .
RUN npm run build                          # compile TS/JS to dist

# 3. Runtime: bind to $PORT
#    Render injects $PORT (default 10000) and HEALTHCHECK hits this port
ENTRYPOINT ["sh","-c", \
  "npx -y @metamcp/mcp-server-metamcp@latest \
     --transport sse \
     --port $PORT \
     --metamcp-api-key $METAMCP_API_KEY"]
