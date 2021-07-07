FROM alpine:3.14

RUN apk update && apk add --no-cache bash ruby-irb nodejs npm \
  && gem install --no-document image_optim image_optim_pack \
  && npm -g install svgo

COPY ./optimize.rb /optimize.rb

ENTRYPOINT ["/optimize.rb"]
