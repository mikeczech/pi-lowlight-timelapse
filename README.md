# Pi Low-light Timelapse

Code for continuously capturing and storing low-light images using a Raspberry PI (+ [picamera](https://picamera.readthedocs.io/en/release-1.13/)) and GCS.

## Requirements

* Python >=3.5 and pipenv
* Google Cloud SDK
* Raspberry PI + camera

## How to use it?

To create the necessary infrastructure (e.g. a GCS bucket for storing images), run

```bash
export GCP_PROJECT_ID=your project
export GOOGLE_APPLICATION_CREDENTIALS=path/to/your/key
./run.sh tf apply
```

To start capturing, run

```bash
./run.sh capture
```
