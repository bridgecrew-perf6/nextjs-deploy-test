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
COPY --from=BUILD_IMAGE /usr/src/app/.next /home/node/app/.next
COPY --from=BUILD_IMAGE /usr/src/app/public /home/node/app/public

EXPOSE 3000
CMD ["node_modules/.bin/next", "start"]