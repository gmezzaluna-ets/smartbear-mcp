FROM node:24-alpine AS builder

# Must be entire project because `prepare` script is run during dependency installation and requires all files.
WORKDIR /app

COPY src/ ./src/
COPY package.json package-lock.json tsconfig.json ./

RUN --mount=type=cache,target=/root/.npm npm install

RUN npm run build

FROM builder AS tester

RUN npm run test:run

FROM node:24-alpine AS release

COPY --from=builder /app/src /app/src
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

ENV NODE_ENV=production

WORKDIR /app

RUN --mount=type=cache,target=/root/.npm-production npm install --ignore-scripts --omit-dev

ENTRYPOINT ["node", "dist/index.js"]
