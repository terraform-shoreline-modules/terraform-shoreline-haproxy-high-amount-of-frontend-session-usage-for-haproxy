terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "high_backend_session_usage_in_haproxy" {
  source    = "./modules/high_backend_session_usage_in_haproxy"

  providers = {
    shoreline = shoreline
  }
}