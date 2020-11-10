variable "atlas_org_id" {
    type = string
    description = "Atlas Org ID"
}

variable "atlas_project_id" {
    description = "id of the MongoDB Atlas Project to use"
}

variable "atlas_public_key" {
    type = string
    description = "The public API Key for MongoDB Atlas"
    
}

variable "atlas_private_key" {
    type = string
    description = "The private API Key for MongoDB Atlas"
    
}

variable "atlas_dbuser" { 
    description = "The db user for the application"
}

variable "atlas_dbpassword" { 
    description = "The db user password for Atlas"
}

variable "atlas_region" {
    default = "GERMANY_WEST_CENTRAL"
    description = "Atlas Region"
}

variable "atlas_vpc_cidr" {
    type = string
    description = "Atlas CIDR"
}

# Azure #######

variable "azure_directory_id" {
    type = string
    description = "Azure Directory ID"
}

variable "azure_subscription_id" {
    type = string
    description = "Azure Subscription ID"
}

variable "azure_region" {
    type = string
    description = "Azure Region"
    default = "Germany West Central"
}

variable "azure_atlas_peering_service_principle_id" {
    type = string
    description = "Service Principle ID"
}