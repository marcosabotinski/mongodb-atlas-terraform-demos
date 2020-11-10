provider "mongodbatlas" {
    public_key  = var.atlas_public_key
    private_key = var.atlas_private_key
}


resource "mongodbatlas_cluster" "cluster-test" {
    project_id = var.atlas_project_id
    name       = "cluster-test"
    num_shards = 1

    mongo_db_major_version       = 4.4
    provider_backup_enabled      = true
    auto_scaling_disk_gb_enabled = true

    provider_name                = "GCP"
    provider_instance_size_name  = "M10"
    provider_region_name         = var.atlas_region

    depends_on = [google_compute_network_peering.peering]
}

resource "mongodbatlas_database_user" "db-user" {
    username           = var.atlas_dbuser
    password           = var.atlas_dbpassword
    auth_database_name = "admin"
    project_id         = var.atlas_project_id
    roles {
        role_name      = "readWriteAnyDatabase"
        database_name  = "admin"
    }
}

resource "mongodbatlas_network_container" "atlas_container" {
    project_id       = var.atlas_project_id
    atlas_cidr_block = var.atlas_vpc_cidr
    provider_name    = "GCP"
}

data "mongodbatlas_network_container" "atlas_container" {
    container_id = mongodbatlas_network_container.atlas_container.container_id
    project_id   = var.atlas_project_id  
}

resource "mongodbatlas_network_peering" "gcp-atlas" {
    project_id            = var.atlas_project_id
    container_id          = mongodbatlas_network_container.atlas_container.container_id
    provider_name         = "GCP"
    gcp_project_id        = var.gcp_project_id
    network_name          = google_compute_network.vpc_network.name
}

resource "google_compute_network_peering" "peering" {
  name         = "peering-gcp-terraform-test"
  network      = google_compute_network.vpc_network.self_link
  peer_network = "https://www.googleapis.com/compute/v1/projects/${mongodbatlas_network_peering.gcp-atlas.atlas_gcp_project_id}/global/networks/${mongodbatlas_network_peering.gcp-atlas.atlas_vpc_name}"
}