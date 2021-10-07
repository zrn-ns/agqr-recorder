#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import eyed3
from datetime import datetime, timedelta, timezone
from dataclasses import dataclass
from typing import List, Dict
import os
import pathlib
import yaml
import threading
import ffmpeg
import shutil
import pathlib

data_directory_path: str = "/agqr-recorder-data/"
config_file_name: str = "config.yaml"
thumb_dir_name: str = "thumbs"
record_dir_name: str = "recorded"
record_root_dir_path: str = data_directory_path + record_dir_name + "/"

tmp_dir_path: str = "/tmp/"

@dataclass
class Schedule:
    title: str
    identifier: str
    weekday: str
    time: str
    length_minutes: int
    thumb_file_name: str
    artist_name: str

    def song_title(self) -> str:
        tz = timezone(timedelta(hours=9))
        now = datetime.now(tz)
        return now.strftime("%Y%m%d") + "_" + self.title

    def album_name(self) -> str:
        return self.title
        
    def thumb_file_path(self) -> str:
        return data_directory_path + thumb_dir_name + "/" + self.thumb_file_name

    def record_dir_path(self) -> str:
        return record_root_dir_path + self.identifier + "/"

    def record_file_name(self) -> str:
        tz = timezone(timedelta(hours=9))
        now = datetime.now(tz)
        return now.strftime("%Y%m%d") + "_" + self.identifier

    def record_file_path(self, format: str) -> str:
        return self.record_dir_path() + self.record_file_name() + "." + format

    def tmp_file_path(self, format: str) -> str:
        return tmp_dir_path + self.record_file_name() + "." + format

    def needs_to_start_recording(self, current_date: datetime) -> bool:
        today_weekday = current_date.strftime("%a")
        current_time_str = current_date.strftime("%H:%M")
        return today_weekday == self.weekday and current_time_str == self.time

class Config:
    path_to_settings_yaml: str = data_directory_path + config_file_name

    stream_url: str = ""
    format: str = "mp3"
    schedules: List[Schedule] = []

    def __init__(self):
        self.load()

    def load(self):
        with open(self.path_to_settings_yaml) as file:
            config = yaml.safe_load(file)
            self.stream_url = config["agqr_stream_url"]
            self.schedules = []
            for schedule in config["schedules"]:
                # 時間を0埋めする(8:00 -> 08:00)
                time = schedule["time"]
                if len(time) == 4:
                    time = "0" + time

                schedule = Schedule(schedule["title"], schedule["identifier"], schedule["weekday"], time, schedule["length_minutes"], schedule["thumb_file_name"], schedule["artist_name"])
                self.schedules.append(schedule)

class AgqrRecorder:
    @staticmethod
    def run():
        now = datetime.now()
        config = Config()

        for schedule in config.schedules:
            if schedule.needs_to_start_recording(now):
                AgqrRecorder.start_recording(config.stream_url, config.format, schedule)
                # 複数番組の同時録画は対応しない（ストリームは一つだけなので問題ないはず）
                return 

    @staticmethod
    def start_recording(stream_url: str, format: str, schedule: Schedule):
        os.makedirs(schedule.record_dir_path(), exist_ok=True)
        os.makedirs(tmp_dir_path, exist_ok=True)
        tmp_file_path = schedule.tmp_file_path(format)
        # タイムアウトはmicroseconds単位で設定(30秒)
        ffmpeg.input(stream_url, t=schedule.length_minutes * 60).output(tmp_file_path, movflags="faststart").overwrite_output().global_args('-timeout', '30000000').run()
        
        # ID3タグを埋め込み
        AgqrRecorder.embed_id3_tag(file_path=tmp_file_path, schedule=schedule)

        shutil.copyfile(tmp_file_path, schedule.record_file_path(format))
        os.remove(tmp_file_path)

    @staticmethod
    def embed_id3_tag(file_path: str, schedule: Schedule):
        cover_img_path = schedule.thumb_file_path()

        tag = eyed3.load(file_path).tag
        tag.version = eyed3.id3.ID3_V2_4
        tag.encoding = eyed3.id3.UTF_8_ENCODING
        tag.artist = schedule.artist_name
        tag.album_artist = schedule.artist_name
        tag.album = schedule.album_name()
        tag.title = schedule.song_title()

        thumb_extension = os.path.splitext(schedule.thumb_file_path())[1][1:]
        tag.images.set(eyed3.id3.frames.ImageFrame.OTHER, open(cover_img_path, "rb").read(), "image/" + thumb_extension)

        tag.save()

if __name__ == "__main__":
    AgqrRecorder.run()
