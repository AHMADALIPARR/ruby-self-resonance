# SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0
# Copyright (C) 2026 SnapKitty Collective
# Multi-stage setup for a sovereign TheVoidIntent runtime environment

# --- Stage 1: Ruby Core & Immutability Verification Engine ---
FROM ruby:3.2-slim AS backend-builder
WORKDIR /usr/src/void_core

# Install minimal cryptographic system utilities
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

COPY package.json ./
COPY git_locksmith.rb initialization_matrix.rb codex_absorber.rb ./
RUN ruby -e "puts 'Backend baseline modules staged.'"

# --- Stage 2: TypeScript Runtime Environment ---
FROM node:20-slim AS runtime-engine
WORKDIR /app

# Pull verified artifacts from the core builder environment
COPY --from=backend-builder /usr/src/void_core /app

COPY ethical_guardrails.ts runtime_pipeline.ts network_alert.ts intent_manifest.yaml ./
RUN npm install -g typescript && tsc *.ts

# Force execution parameters to anchor onto the 1/13 baseline constant configuration
ENV VOID_RESONANCE_INDEX=0.076923
ENV STAGE_THRESHOLD=44.0

# Initialize via the 44-Stage Progressive Matrix before firing the runtime loop
CMD ["node", "runtime_pipeline.js"]
