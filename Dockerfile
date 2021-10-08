FROM ubuntu:18.04

MAINTAINER zrn-ns

RUN apt-get update

# add repository(streamlink)
RUN apt-get install software-properties-common -y -qq --no-install-recommends
RUN add-apt-repository ppa:nilarimogard/webupd8

# 日本語環境化
RUN apt-get install -y language-pack-ja-base language-pack-ja locales tzdata; \
    locale-gen ja_JP.UTF-8
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8

# データディレクトリ
VOLUME /agqr-recorder-data/config/
VOLUME /agqr-recorder-data/recorded/

# Install ffmpeg
RUN apt-get install ffmpeg -y -qq --no-install-recommends

# Install streamlink
RUN apt-get install streamlink -y -qq --no-install-recommends

# Install python
RUN apt-get install python3 python3-pip python3-setuptools -y -qq --no-install-recommends
RUN pip3 install --upgrade pip

# Install other tools
RUN apt-get install vim -y -qq --no-install-recommends

# copy applications
COPY app/ /usr/src/app/

# install Python modules needed by the Python app
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt

CMD ["/usr/src/app/startup.sh"]
