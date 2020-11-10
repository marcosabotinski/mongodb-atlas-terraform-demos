provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "example" { 
    name        = "azure-app-atlas"
    location    = var.azure_region
}


resource "azurerm_virtual_network" "example" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_role_definition" "example" {
  name               = "AtlasPeering/${var.azure_subscription_id}/${azurerm_resource_group.example.name}/${azurerm_virtual_network.example.name}"
  scope              = "/subscriptions/${var.azure_subscription_id}"
  description        = "Grants MongoDB access to manage peering connections"

  permissions {
    actions     = ["Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
                   "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
                   "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
                   "Microsoft.Network/virtualNetworks/peer/action"]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_resource_group.example.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.example.name}"
  ]
}

resource "azurerm_role_assignment" "example" {
  scope              = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_resource_group.example.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.example.name}"
  role_definition_id = azurerm_role_definition.example.role_definition_resource_id
  principal_id       = var.azure_atlas_peering_service_principle_id
}