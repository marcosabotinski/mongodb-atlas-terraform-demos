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
    default = "EU_CENTRAL_1"
    description = "Atlas Region"
}

variable "atlas_vpc_cidr" {
    type = string
    description = "Atlas CIDR"
}

# AWS #######

variable "aws_account_id" {
    type = string
    description = "AWS Account ID"
}

variable "aws_region" {
    type = string
    description = "Aws Region"
    default = "eu-central-1"
}

variable "key_name" {
    type = string
    description = "SSH Key Name"
}

variable "key_path" {
    type = string
    description = "SSH Key Path"
}