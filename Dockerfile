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

# # https://stackoverflow.com/questions/5178416/libxml-install-error-using-pip
# RUN apt install libxml2-dev libxslt-dev -y -qq --no-install-recommends

# Install ffmpeg
RUN apt install ffmpeg -y -qq --no-install-recommends

# Install python
RUN apt install python3 python3-dev python3-pip python3-setuptools python3-lxml -y -qq --no-install-recommends

# Setup virtualenv
RUN pip install --upgrade virtualenv
RUN virtualenv ~/myenv
RUN ls -alF ~/myenv/bin/
RUN . ~/myenv/bin/activate

# Install streamlink
RUN pip3 install --upgrade streamlink

# Install other tools
RUN apt install vim -y -qq --no-install-recommends

# copy applications
COPY app/ /usr/src/app/

# install Python modules needed by the Python app
RUN pip3 install --no-cache-dir -r /usr/src/app/requirements.txt

CMD ["/usr/src/app/startup.sh"]
