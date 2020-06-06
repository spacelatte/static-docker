#!/usr/bin/env -S docker build --compress -t pvtmert/flask -f

FROM python:3-slim

RUN python3 -m pip install -U flask

ONBUILD RUN python3 -m pip install -U flask
