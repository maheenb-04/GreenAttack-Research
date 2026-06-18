FROM --platform=linux/amd64 python:3.8-bullseye

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

COPY reset-requirements.txt .

RUN python -m pip install --upgrade "pip<24" setuptools wheel
RUN python -m pip install -r reset-requirements.txt

CMD ["/bin/bash"]