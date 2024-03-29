terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.60.0"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 4.60"
    }
  }
}