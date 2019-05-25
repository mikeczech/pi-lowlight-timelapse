variable "project" {}

provider "google" {
  project     = "${var.project}"
  region      = "us-central1"
}

resource "google_storage_bucket" "image-store" {
  name     = "${ var.project }-image-store-bucket"
  location = "US"
}

resource "google_service_account" "image-writer" {
  account_id = "image-writer"
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = "${ google_storage_bucket.image-store.name }"
  role        = "roles/storage.admin"

  members = [
    "serviceAccount:${ google_service_account.image-writer.email }",
  ]
}
