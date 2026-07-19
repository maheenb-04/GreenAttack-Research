FROM python:3.9-bullseye

WORKDIR /workspace

ENV MPLBACKEND=Agg
ENV TF_CPP_MIN_LOG_LEVEL=3
ENV CUDA_VISIBLE_DEVICES=-1
ENV TF_ENABLE_ONEDNN_OPTS=0

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    libgl1 \
    libglib2.0-0 \
    tini \
    && rm -rf /var/lib/apt/lists/*

COPY cleaned-requirements.txt .

RUN python -m pip install --upgrade pip setuptools wheel
RUN python -m pip install -r cleaned-requirements.txt

RUN cat > /usr/local/bin/tf_kernel_launcher.py <<'PY'
import os

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "3")
os.environ.setdefault("CUDA_VISIBLE_DEVICES", "-1")
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")
os.environ.setdefault("MPLBACKEND", "Agg")

print("Preloading TensorFlow before ipykernel starts...", flush=True)
import tensorflow as tf

print("Preloading matplotlib Agg backend before ipykernel starts...", flush=True)
import matplotlib
matplotlib.use("Agg", force=True)
import matplotlib.pyplot as plt

print("Preloads complete. Starting ipykernel...", flush=True)
from ipykernel.kernelapp import IPKernelApp
IPKernelApp.launch_instance()
PY

RUN chmod +x /usr/local/bin/tf_kernel_launcher.py \
    && mkdir -p /usr/local/share/jupyter/kernels/python3 \
    && cat > /usr/local/share/jupyter/kernels/python3/kernel.json <<'JSON'
{
  "argv": [
    "python",
    "/usr/local/bin/tf_kernel_launcher.py",
    "-f",
    "{connection_file}"
  ],
  "display_name": "Python 3 TensorFlow Preload",
  "language": "python"
}
JSON

EXPOSE 8888

ENTRYPOINT ["tini", "--"]

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=", "--NotebookApp.password="]
