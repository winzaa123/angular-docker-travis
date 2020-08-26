# FROM node:12.13-alpine as install
# WORKDIR /app

# COPY package.json .
# COPY package-lock.json* .

# COPY local-lib local-lib

# RUN npm i

FROM node:14.8.0-alpine as  builder 

RUN mkdir -p /srv && chown -R node:node /srv
USER node
WORKDIR /srv

ENV PATH=${PATH}:./node_modules/.bin
ENV NODE_PATH=/srv/node_modules

ADD  package.json package-lock.json*  ./

# COPY local-lib local-lib

RUN npm ci
# RUN ngcc
# COPY --from=install /app/ /srv/
# https://medium.com/@nicolas.tresegnie/angular-docker-speed-up-your-builds-with-ngcc-b4f5b0987f46
# RUN ./node_modules/.bin/ngcc  --properties es2015 browser module main --create-ivy-entry-points
# RUN ./node_modules/.bin/ngcc --properties es2015  --create-ivy-entry-points
# RUN ./node_modules/.bin/ngcc --properties es2015
COPY . .
RUN ng build --output-path=./dist/out


FROM nginx:1.17-alpine
ADD ./production-config.conf  /etc/nginx/nginx.conf
COPY --from=builder /srv/dist/out /usr/share/nginx/html
# CMD ["nginx","-g","daemon off"]
