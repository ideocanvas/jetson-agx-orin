FROM dustynv/pytorch:2.7-r36.4.0-cu128-24.04

# Switch to app user
USER root

ENV PIP_INDEX_URL=https://pypi.jetson-ai-lab.io/jp6/cu128

# Create app user and working directory
RUN useradd -m app && \
    mkdir -p /home/app/bitsandbytes && \
    chown app:app /home/app

RUN apt update; apt install -y ffmpeg

WORKDIR /home/app/bitsandbytes

ADD bitsandbytes/build.sh .

RUN cd /home/app/bitsandbytes && ./build.sh

WORKDIR /home/app/

RUN git clone https://github.com/comfyanonymous/ComfyUI.git

WORKDIR /home/app/ComfyUI

RUN pip install -r requirements.txt

WORKDIR /home/app/

ADD entrypoint.sh .

# Set the entrypoint
ENTRYPOINT ["bash", "entrypoint.sh"]