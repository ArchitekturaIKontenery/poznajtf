terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "=3.0.0"
        }

        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0.0"
        }

        google = {
            source  = "hashicorp/google"
            version = ">= 3.60, < 4.0"
        }
    }
}