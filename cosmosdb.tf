resource "azurerm_cosmosdb_account" "cosmos" {
  name                      = "cosmosdb-serverless-demo"
  location                  = azurerm_resource_group.demo.location
  resource_group_name       = azurerm_resource_group.demo.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_free_tier          = true
  enable_automatic_failover = false

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.demo.location
    failover_priority = 0
  }
}

# resource "azurerm_role_assignment" "func" {
#   scope                = azurerm_cosmosdb_account.cosmos.id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_user_assigned_identity.func.principal_id
# }