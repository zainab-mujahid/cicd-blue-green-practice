FROM node:22-alpine AS deps
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci


FROM node:22-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
RUN npm run build


FROM node:22-alpine AS runner
WORKDIR /usr/src/app
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
RUN adduser --system --uid 1001 --ingroup node nextjs
COPY --from=builder --chown=nextjs:node /usr/src/app/.next/standalone ./
COPY --from=builder --chown=nextjs:node /usr/src/app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:node /usr/src/app/public ./public
USER nextjs
EXPOSE 3000

CMD ["node", "server.js"]
