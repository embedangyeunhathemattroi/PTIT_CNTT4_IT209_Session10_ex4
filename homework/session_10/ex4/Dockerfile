FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN apk add --no-cache iputils && npm install --omit=dev

COPY server.js ./

ENV PORT=3000

EXPOSE 3000

CMD ["node", "server.js"]
