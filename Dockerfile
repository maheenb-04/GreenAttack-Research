FROM python:3.9-bullseye

WORKDIR /workspace

# Headless/container-safe runtime defaults.
# Agg prevents matplotlib.pyplot from trying to use an interactive GUI backend.
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

RUN python -m pip install --upgrade "pip<24" setuptools wheel
RUN python -m pip install -r cleaned-requirements.txt

# Start notebook kernels through a small launcher that preloads TensorFlow and
# matplotlib before ipykernel begins processing cell execution requests. This
# avoids hangs seen when importing TensorFlow/Keras or pyplot from inside an
# active ipykernel request under linux/amd64 emulation.
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