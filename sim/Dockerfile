FROM node:22.11.0-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends git python3 ca-certificates procps \
  && rm -rf /var/lib/apt/lists/*
RUN npm install -g @anthropic-ai/claude-code@2.1.295
COPY gh sim-merge sim-close /usr/local/bin/
RUN chmod +x /usr/local/bin/gh /usr/local/bin/sim-merge /usr/local/bin/sim-close
USER node
ENV GH_DATA=/work/github CLAUDE_CONFIG_DIR=/work/claude-home \
  GIT_AUTHOR_NAME=sim GIT_AUTHOR_EMAIL=sim@example.com GIT_COMMITTER_NAME=sim GIT_COMMITTER_EMAIL=sim@example.com
WORKDIR /work/sim
