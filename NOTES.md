# NOTES.md

## Purpose

This project was originally developed several years ago against a Python and machine learning ecosystem that has since changed significantly. Many of the original package versions are no longer available, have been yanked from PyPI, or are incompatible with modern Python releases and Apple Silicon hardware.

The goal of this repository update is to preserve a reproducible environment capable of running the original notebooks and experiments with minimal modification to the research code.

## Docker-Based Compatibility Environment

A Docker image is provided to recreate a working execution environment for the project.

The Docker environment prioritizes:

- Reproducibility
- Ease of setup
- Cross-platform compatibility
- Preservation of the original experiment workflow

The Docker image does **not** prioritize performance. On Apple Silicon systems the container runs using x86_64 (`linux/amd64`) emulation through Docker Desktop.

## Major Dependency Adjustments

Several package versions from the original environment were no longer available or could not be installed successfully on modern systems.

The following notable changes were required:

| Component | Original | Updated |
|------------|----------|----------|
| Python | Legacy environment | Python 3.9 |
| TensorFlow | 2.6.0 | 2.12.0 |
| NumPy | Various legacy pins | 1.23.5 |
| OpenCV | 4.5.2.52 | 4.5.3.56 |
| QtPy | 1.9.0 | 2.0.1 |
| setuptools | Unspecified | 68.2.2 |
| lxml_html_clean | Not required originally | Added |

## Issues Encountered

During reconstruction of the environment several incompatibilities were identified:

### Python 3.12 Compatibility

Older scientific packages used by this project do not support Python 3.12.

Examples include:

- GPy
- GPyOpt
- paramz
- scikit-image 0.18.x

Python 3.9 was selected as the most practical compatibility target.

### NumPy ABI Changes

Modern NumPy releases introduced API and ABI changes that caused failures in older scientific packages.

Examples included:

- `numpy.lib.function_base` import failures
- Binary incompatibility warnings
- GPy/paramz runtime failures

Pinning NumPy to 1.23.5 resolved these issues.

### TensorFlow Compatibility

The original TensorFlow version specified by the project was incompatible with the selected scientific stack.

TensorFlow 2.12.0 provided the best balance between:

- Python 3.9 support
- NumPy 1.23.x compatibility
- Availability of prebuilt wheels

### Jupyter Notebook Compatibility

The original notebook stack required additional adjustments:

- Pinning older notebook-related packages
- Pinning jsonschema
- Installing `lxml_html_clean`

Without these changes notebook rendering failed.

## GPU Acceleration

The provided Docker image is intended primarily for CPU execution.

### Apple Silicon (M-Series Macs)

GPU acceleration is not currently available inside the provided Docker image.

The image runs under:

```text
linux/amd64
```

emulation and executes using CPU resources.

### NVIDIA GPUs

Future users may be able to enable GPU acceleration on Linux hosts using:

- NVIDIA drivers
- NVIDIA Container Toolkit
- Compatible TensorFlow builds

This has not been tested as part of the current reconstruction effort.

## Verification

The reconstructed environment was validated by successfully importing:

```python
import GPy
import GPyOpt
import skimage
import cv2
import tensorflow
```

and launching the supplied Jupyter notebooks.

## Future Improvements

Potential future work includes:

- Native Apple Silicon support
- Migration to modern TensorFlow releases
- Migration away from deprecated GPy/GPyOpt dependencies
- Automated Docker image publication via GitHub Actions
- Multi-architecture container images

Until such work is completed, the Docker environment should be considered the canonical execution environment for this project.