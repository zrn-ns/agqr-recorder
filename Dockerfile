FROM ubuntu:18.04

MAINTAINER zrn-ns

RUN apt-get update

# 日本語環境化
RUN apt-get install -y language-pack-ja-base language-pack-ja locales tzdata; \
    locale-gen ja_JP.UTF-8
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8

# データディレクトリ
VOLUME /agqr-recorder-data/

# Install tools
RUN apt-get install python3 python3-pip vim ffmpeg python3-setuptools -y -qq --no-install-recommends
RUN pip3 install --upgrade pip

# copy applications
COPY app/ /usr/src/app/

# install Python modules needed by the Python app
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt

CMD ["/usr/src/app/startup.sh"]
