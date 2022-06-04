FROM ubuntu:22.04

MAINTAINER zrn-ns

RUN apt-get update

# 日本語環境化
RUN apt-get install -y language-pack-ja-base language-pack-ja locales tzdata; \
    locale-gen ja_JP.UTF-8
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8

# データディレクトリ
VOLUME /agqr-recorder-data/config/
VOLUME /agqr-recorder-data/recorded/

# Setup python
RUN apt-get install software-properties-common python3 python3-pip -y -qq

# Install ffmpeg
RUN apt-get install ffmpeg -y -qq --no-install-recommends

# Install streamlink
RUN apt-get install libxml2-dev libxslt-dev python3-dev -y -qq
RUN pip3 install --upgrade setuptools
RUN pip3 install --upgrade streamlink

# Install other tools
RUN apt-get install vim -y -qq --no-install-recommends

# copy applications
COPY app/ /usr/src/app/

# install Python modules needed by the Python app
RUN pip3 install --no-cache-dir -r /usr/src/app/requirements.txt

CMD ["/usr/src/app/startup.sh"]
