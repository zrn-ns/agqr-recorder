#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from agqr_recorder import AgqrRecorder
from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.triggers.cron import CronTrigger

scheduler = BlockingScheduler()
scheduler.add_job(AgqrRecorder.run, CronTrigger.from_crontab("* * * * *"), max_instances=2)

scheduler.start()
