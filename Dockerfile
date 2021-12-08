# == Stage 1 - Build Front-End Assets ==
# Set the base image to use for any subsequent instructions that follow and also give this build stage a name.
## Use node image with apline tag, lightweight image to leverage node and build the app
FROM node:12.16.3-alpine as build
# The path to use as the working directory. Will be created if it does not exist.
# Set the working directory for any ADD, COPY, CMD, ENTRYPOINT, or RUN instructions that follow.
## Directoy in container that will contain the code
WORKDIR /app
# Copy new files and directories to the image's filesystem.
## Copy package*.json into /app to when npm is installed it can create nodue modules with that config
COPY package*.json ./
# The command to run. Execute commands inside a shell.
## Install npm in container
RUN npm install
## Copy results of npm install into root of workdir
COPY . .
## Run app as development build
RUN npm run build

# == Stage 2 - Serve Front-End Assets ==
## Pull nginx image from Dockerhub
FROM nginx:stable-alpine
## set new workdir in this container
WORKDIR /etc/nginx
## add nginx configuration into where its expected to be found
ADD nginx.conf /etc/nginx/nginx.conf
## copy from build stage the build folder that is generated when 'npm run build' is run. Target dir is where nginx expects the files to be
COPY --from=build /app/build /usr/share/nginx/html
# The port that this container should listen on. Define network ports for this container to listen on at runtime.
## use https, expose port 443 (could expose port 80)
EXPOSE 443
# Set the default executable and parameters for this executing container.
## turn on and run nginx
CMD ["nginx", "-g", "daemon off;"]
