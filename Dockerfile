FROM ubuntu:22.04

MAINTAINER zrn-ns

RUN apt update

# 日本語環境化
RUN apt-get install -y language-pack-ja-base language-pack-ja locales tzdata; \
    locale-gen ja_JP.UTF-8
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8

# データディレクトリ
VOLUME /agqr-recorder-data/config/
VOLUME /agqr-recorder-data/recorded/

# https://stackoverflow.com/questions/5178416/libxml-install-error-using-pip
RUN apt-get install libxml2-dev libxslt-dev python3-dev -y -qq --no-install-recommends
# https://stackoverflow.com/questions/33785755/getting-could-not-find-function-xmlcheckversion-in-library-libxml2-is-libxml2
RUN pip3 install lxml

# Install ffmpeg
RUN apt-get install ffmpeg -y -qq --no-install-recommends

# Install python
RUN apt-get install python3 python3-pip python3-setuptools -y -qq --no-install-recommends
RUN pip3 install --upgrade pip setuptools

# Install streamlink
RUN pip3 install --upgrade streamlink

# Install other tools
RUN apt-get install vim -y -qq --no-install-recommends

# copy applications
COPY app/ /usr/src/app/

# install Python modules needed by the Python app
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt

CMD ["/usr/src/app/startup.sh"]
