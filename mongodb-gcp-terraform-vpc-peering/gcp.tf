provider "google" {
  credentials = file("credentials.json")
  region      = "europe-west3"
}


resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
  auto_create_subnetworks = true
  project = var.gcp_project_id
}