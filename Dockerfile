# FROM node:12.13-alpine as install
# WORKDIR /app

# COPY package.json .
# COPY package-lock.json* .

# COPY local-lib local-lib

# RUN npm i

FROM node:14.8.0-alpine as  builder 

RUN mkdir -p /home/app && chown -R node:node /home/app
USER node
WORKDIR /home/app

ENV PATH=${PATH}:./node_modules/.bin
ENV NODE_PATH=/home/app/node_modules

COPY package.json package-lock.json ./

# COPY local-lib local-lib

RUN npm ci
# RUN ngcc
# COPY --from=install /app/ /home/app/
# https://medium.com/@nicolas.tresegnie/angular-docker-speed-up-your-builds-with-ngcc-b4f5b0987f46
# RUN ./node_modules/.bin/ngcc  --properties es2015 browser module main --create-ivy-entry-points
# RUN ./node_modules/.bin/ngcc --properties es2015  --create-ivy-entry-points
# RUN ./node_modules/.bin/ngcc --properties es2015
COPY . .
RUN ng build --output-path=./dist/out


FROM nginx:1.17-alpine
ADD ./production-config.conf  /etc/nginx/nginx.conf
COPY --from=builder /home/app/dist/out /usr/share/nginx/html
# CMD ["nginx","-g","daemon off"]
