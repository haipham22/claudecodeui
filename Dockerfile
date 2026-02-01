# Use Node.js 18-alpine for a smaller image size
FROM node:22-alpine AS base

# Install build dependencies
RUN apk add --no-cache python3 make g++ git openssh-client

# Set up MCP detection and TaskMaster support (packages installed at runtime)

FROM base AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install task-master-ai as global
RUN npm i -g task-master-ai

# Install all dependencies (including dev for build)
RUN npm ci

# Copy source code
COPY . .

# Build the client
RUN npm run build

# Production stage
FROM base

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server ./server



# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "server/index.js"]
