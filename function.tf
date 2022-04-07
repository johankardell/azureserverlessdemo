resource "azurerm_storage_account" "funcsa" {
  name                     = "funcsaserverlessdemojk"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

}

resource "azurerm_app_service_plan" "asp" {
  name                = "asp-serverless-demo"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  reserved            = "true"
  kind                = "elastic"

  // No container support when running serverless
  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "func" {
  name                = "func-serverless-demo"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  storage_account_name       = azurerm_storage_account.funcsa.name
  storage_account_access_key = azurerm_storage_account.funcsa.primary_access_key
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  version                    = "~4"
  os_type                    = "linux"

  app_settings = {
    COSMOS_DB_ENDPOINT              = azurerm_cosmosdb_account.cosmos.endpoint
    COSMOS_DB_MASTERKEY             = azurerm_cosmosdb_account.cosmos.primary_key
    DOCKER_REGISTRY_SERVER_URL      = "https://mcr.microsoft.com"
    DOCKER_REGISTRY_SERVER_USERNAME = ""
    DOCKER_REGISTRY_SERVER_PASSWORD = ""
    # WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
  }

  site_config {
    dotnet_framework_version = "V6.0"
    linux_fx_version         = "DOCKER|mcr.microsoft.com/azuredocs/azure-vote-front:cosmosdb"
  }

  #   identity {
  #     identity_ids = [azurerm_user_assigned_identity.func.id]
  #     type = "UserAssigned"
  #   }
}

# resource "azurerm_user_assigned_identity" "func" {
#     name = "id-func-demo"
#     resource_group_name = azurerm_resource_group.demo.name
#     location = azurerm_resource_group.demo.location

# }
