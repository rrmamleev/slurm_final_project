terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.80"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint          = "storage.yandexcloud.net"
    bucket            = "yelb-state"
    region            = "ru-central1"
    key               = "yelb-state.tfstate"
    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gfef5c864v10atn0a6/etnuqraso14se8eiqve9"
    dynamodb_table    = "yelb-state"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
}
