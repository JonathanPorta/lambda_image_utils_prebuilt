FROM jonathanporta/docker-fedora-node-build-image:latest

ADD . /app

WORKDIR /app

RUN yarn
RUN ./node_modules/.bin/gulp

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-i", "-t", "-c"]
CMD ["node dist/api/app.js"]
