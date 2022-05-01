FROM ghcr.io/neruko-s/nextjs-base-project-dependencies:latest AS BUILD_IMAGE
WORKDIR /usr/src/app
COPY . .
RUN npm run build
RUN npm prune --production
RUN /usr/local/bin/node-prune

# ============================================
FROM ghcr.io/neruko-s/node-base:latest

USER 1000
RUN mkdir -p /home/node/app/
RUN mkdir -p /home/node/app/node_modules
RUN mkdir -p /home/node/app/.next
RUN mkdir -p /home/node/app/public

RUN chown -R 1000:1000 /home/node/app/
RUN chown -R 1000:1000 /home/node/app/node_modules
RUN chown -R 1000:1000 /home/node/app/.next
RUN chown -R 1000:1000 /home/node/app/public

WORKDIR /home/node/app

COPY --from=BUILD_IMAGE /usr/src/app/next.config.js /home/node/app/
COPY --from=BUILD_IMAGE /usr/src/app/node_modules /home/node/app/node_modules
COPY --from=BUILD_IMAGE /usr/src/app/.next /home/node/app/.nest
COPY --from=BUILD_IMAGE /usr/src/app/public /home/node/app/public

EXPOSE 3000
CMD ["node_modules/.bin/next", "start"]


# # 必要なときだけ依存関係をインストール
# FROM node:18-alpine3.14 AS deps
# WORKDIR /opt/app
# COPY package*.json ./
# RUN npm ci

# # 必要なときだけソースコードを再構築する
# # ここで、私の場合は何らかの`X_TAG`（Gitコミットハッシュ）に基づいて
# # アプリを構築しようとする場合がありますが、コードは変わっていません。
# FROM node:18-alpine3.14 AS builder
# ENV NODE_ENV=production
# WORKDIR /opt/app
# COPY . .
# COPY --from=deps /opt/app/node_modules ./node_modules
# RUN npm run build

# # プロダクション・イメージ（本番環境）で、すべてのファイルをコピーし、nextを実行
# FROM node:18-alpine3.14 AS runner

# WORKDIR /opt/app
# ENV NODE_ENV=production
# COPY --from=builder /opt/app/next.config.js ./
# COPY --from=builder /opt/app/public ./public
# COPY --from=builder /opt/app/.next ./.next
# COPY --from=builder /opt/app/node_modules ./node_modules
# CMD ["node_modules/.bin/next", "start"]