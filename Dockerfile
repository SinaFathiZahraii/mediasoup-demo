FROM node:22-bookworm AS builder

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        build-essential \
        gcc \
        g++ \
        make \
        git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY . .

WORKDIR /build/app
RUN npm ci --legacy-peer-deps
RUN npm run build

WORKDIR /build/server
RUN npm ci
RUN npm run typescript:build

# Runtime
#==================
FROM node:22-bookworm-slim


WORKDIR /app

COPY --from=builder /build/server .
COPY --from=builder /build/app/dist ./public

ENV NODE_ENV=production

CMD ["npm","start"]
