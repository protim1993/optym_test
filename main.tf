resource "azurerm_subscription" "Pay-As-You-Go" {
  alias             = "aks_sub"
  subscription_name = "AKS Subscription"
  subscription_id   = "bf70e98c-afb1-4157-ad4d-de064f2354a5"
}

resource "azurerm_resource_group" "AKS_01" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_role_definition" "aks_role" {
  name               = "my-custom-role-definition"
  scope              = azurerm_subscription.Pay-As-You-Go.id

  permissions {
    actions     = ["Microsoft.Resources/subscriptions/resourceGroups/read"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_subscription.id,
  ]
}

resource "azurerm_role_assignment" "example" {
  name               = "00000000-0000-0000-0000-000000000000"
  scope              = "/subscriptions/bf70e98c-afb1-4157-ad4d-de064f2354a5/resourceGroups/azurerm_resource_group.rgname"
  role_definition_id = azurerm_role_definition.example.role_definition_resource_id
  principal_id       = azurerm_client_config.example.object_id
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr
  resource_group_name = azurerm_resource_group.name
  location            = azurerm_resource_group.location
  sku                 = "Standard"
  admin_enabled       = false
  georeplications {
    location                = "East US"
    zone_redundancy_enabled = true
    tags                    = {}
  }
  georeplications {
    location                = "westeurope"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "standard_a2_v2"
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }
}

resource "azurerm_application_gateway" "network" {
  name                = "aks-appgateway"
  resource_group_name = azurerm_resource_group.var.rgname
  location            = azurerm_resource_group.var.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

resource "azurerm_public_ip" "aks_pip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.name
  location            = azurerm_resource_group.location
  allocation_method   = "Static"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_storage_account" "aks_storage" {
  name                     = var.storageaccountname
  resource_group_name      = azurerm_resource_group.name
  location                 = azurerm_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "development"
  }
}

resource "azurerm_key_vault" "example" {
  name                        = var.keyvault
  location                    = azurerm_resource_group.location
  resource_group_name         = azurerm_resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = azurerm_client_config.current.tenant_id
    object_id = azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_sql_server" "sql_server" {
  name                         = var.sql
  resource_group_name          = azurerm_resource_group.name
  location                     = azurerm_resource_group.location
  version                      = var.sqlversion
  administrator_login          = var.adminuser
  administrator_login_password = var.adminpassword

  tags = {
    environment = "production"
  }
}

resource "azurerm_sql_elasticpool" "example" {
  name                = var.elasticpool
  resource_group_name = azurerm_resource_group.name
  location            = azurerm_resource_group.location
  server_name         = azurerm_sql_server.name
  edition             = "Basic"
  dtu                 = 50
  db_dtu_min          = 0
  db_dtu_max          = 5
  pool_size           = 5000
}