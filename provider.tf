terraform {
    
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.45.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "e947b393-1d0f-4eb5-982d-d262872525ff"
} 