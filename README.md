# Intro
This repository contains four demos to illustrate how to automate MongoDB Atlas with the different Cloud Providers. The demos require that you have basic knowledge of the corresponding cloud provider.

## Prerequisites
* Knowledge of the choosen cloud provider 
* API Keys / Credentials for Atlas and cloud provider Setup
* Permissions to create ressources
* Terraform installed

## Demos
* `mongodb-aws-terraform-private-link`: AWS Demo that uses Private Link for Network Access. It also created a VM that insert a demo record into MongoDB. (End to End Demo)
* `mongodb-aws-terraform-vpc-peering`: AWS Demo that uses VPC Peering for Network Access
* `mongodb-azure-terraform-vnet-peering`: Azure Demo that uses VNET Peering for Network Access
* `mongodb-gcp-terraform-vpc-peering`: GCP Demo that uses VNET Peering for Network Access

