from time import sleep
from picamera import PiCamera
from google.cloud import storage
from io import BytesIO

def upload_blob(bucket_name, file_obj, destination_blob_name):
    """Uploads a file to the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_file(file_obj)

stream = BytesIO()
camera = PiCamera()
camera.start_preview()
sleep(2)
counter = 0
for _ in camera.capture_continuous(stream, format='jpeg'):
    stream.seek(0)
    counter += 1
    filename = "img-{}.jpg".format(counter)
    print("Uploading file {}...".format(filename))
    upload_blob('corded-terrain-224220-image-store-bucket', stream, filename)
    stream.seek(0)
    stream.truncate(0)
    stream.seek(0)
    sleep(2) # wait 5 minutes
