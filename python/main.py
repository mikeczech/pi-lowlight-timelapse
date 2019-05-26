import os
from time import sleep
from picamera import PiCamera
from fractions import Fraction
from google.cloud import storage
from PIL import Image
from io import BytesIO
import uuid


def upload_blob(bucket_name, file_obj, destination_blob_name):
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_file(file_obj)


def get_low_light_cam():
    # Force sensor mode 3 (the long exposure mode), set
    # the framerate to 1/6fps, the shutter speed to 6s,
    # and ISO to 800 (for maximum gain)
    camera = PiCamera(resolution=(1280, 720), framerate=Fraction(1, 6), sensor_mode=3)
    camera.shutter_speed = 6000000
    camera.iso = 800
    # Give the camera a good long time to set gains and
    # measure AWB (you may wish to use fixed AWB instead)
    sleep(30)
    camera.exposure_mode = "off"
    return camera


def main():
    print("Initializing camera...")
    camera = get_low_light_cam()
    try:
        camera.start_preview()
        sleep(2)  # wait for the camera

        capture_id = uuid.uuid4()
        stream = BytesIO()
        counter = 0

        print("Capturing...")
        for _ in camera.capture_continuous(stream, format="jpeg"):
            stream.seek(0)

            # rotate image
            image = Image.open(stream).rotate(180)
            image_bytes = BytesIO()
            image.save(image_bytes, format="jpeg")
            image_bytes.seek(0)

            filename = "{}/img-{:09d}.jpg".format(str(capture_id), counter)
            print(
                "Uploading file {}... ({} bytes)".format(
                    filename, image_bytes.getbuffer().nbytes
                )
            )
            upload_blob(
                "{}-image-store-bucket".format(os.environ["GCP_PROJECT_ID"]),
                image_bytes,
                filename,
            )
            counter += 1

            # reset the stream
            stream.truncate(0)
            stream.seek(0)

            sleep(10)
    finally:
        camera.close()


if __name__ == "__main__":
    main()
