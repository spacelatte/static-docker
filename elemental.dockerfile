#!/usr/bin/env -S docker build --compress -t pvtmert/elemental -f
FROM python:3.7
WORKDIR /data
RUN git clone --depth=1 https://github.com/Elemental-attack/Elemental.git .
RUN pip install -r elemental/requirements.txt
ENV PORT 8000
EXPOSE $PORT
CMD python elemental/manage.py runserver 0.0.0.0:$PORT
