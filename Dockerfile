FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update \
  && apt-get install --no-install-recommends --assume-yes ruby nodejs npm \
  && rm -rf /var/lib/apt/lists/* \
  && gem install --no-document image_optim image_optim_pack \
  && npm -g install svgo

COPY ./optimize.rb /optimize.rb

ENTRYPOINT ["/optimize.rb"]
