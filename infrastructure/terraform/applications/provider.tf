terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-storage-global-weu"
    storage_account_name = "ststorageglobalweu"
    container_name       = "cttfstate"
    key                  = "statebucket/terraform.applications.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "abfeb8a0-afc4-44a4-b1d7-7fd3ddda7d68"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }
  }
}
