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

    provider_name                = "AZURE"
    provider_instance_size_name  = "M10"
    provider_region_name         = var.atlas_region

    depends_on = [mongodbatlas_network_peering.azure-atlas]
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
    provider_name    = "AZURE"
    region           = var.atlas_region
}

data "mongodbatlas_network_container" "atlas_container" {
    container_id = mongodbatlas_network_container.atlas_container.container_id
    project_id   = var.atlas_project_id  
}

resource "mongodbatlas_network_peering" "azure-atlas" {
    project_id            = var.atlas_project_id
    container_id          = mongodbatlas_network_container.atlas_container.container_id
    provider_name         = "AZURE"
    atlas_cidr_block      = mongodbatlas_network_container.atlas_container.atlas_cidr_block
    azure_directory_id    = var.azure_directory_id
    azure_subscription_id = var.azure_subscription_id
    resource_group_name   = azurerm_resource_group.example.name
    vnet_name             = azurerm_virtual_network.example.name
    depends_on            = [azurerm_role_assignment.example]
}