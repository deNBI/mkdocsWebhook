FROM python:3.10.2
ENV WEBHOOK_URL_PREFIX="wiki/hooks"
RUN apt update
RUN apt install -y unzip apache2 build-essential python3-dev python3-pip python3-setuptools python3-wheel python3-cffi libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info
ADD requirements.txt .
RUN python -m pip  install -r requirements.txt
RUN wget -qO- https://github.com/adnanh/webhook/releases/download/2.6.5/webhook-linux-amd64.tar.gz \ 
      | tar xzv --strip 1  -C  /usr/local/bin
RUN mkdir -p /var/webhook /srv_root/docs 
ADD update.sh /usr/local/bin/update.sh
COPY config/hooks.json /usr/local/bin/hooks.json
COPY config/apache2.conf /etc/apache2/apache2.conf
ADD start.sh /usr/local/bin/start.sh
RUN mkdir /var/www/html/wiki
ENTRYPOINT "start.sh"
