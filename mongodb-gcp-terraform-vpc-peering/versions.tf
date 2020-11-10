terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
  required_version = ">= 0.13"
}
