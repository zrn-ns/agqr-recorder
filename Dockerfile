FROM ubuntu:18.04

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

RUN apt install software-properties-common curl -y -qq
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install python3.9 python3-distutils python3-apt -y -qq --no-install-recommends
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.9 -

RUN python3.9 -V
RUN pip3 -V

# Install streamlink
RUN pip3 install --upgrade setuptools
#RUN pip3 install --upgrade libxml2-python3 libxml2-devel libxslt
#RUN pip3 install --upgrade streamlink
RUN apt install git -y -qq
RUN git --version
RUN pip3 install --upgrade git+https://github.com/streamlink/streamlink.git@ea7a243

# Install other tools
RUN apt install vim -y -qq --no-install-recommends

# copy applications
COPY app/ /usr/src/app/

# install Python modules needed by the Python app
RUN pip3 install --no-cache-dir -r /usr/src/app/requirements.txt

CMD ["/usr/src/app/startup.sh"]
