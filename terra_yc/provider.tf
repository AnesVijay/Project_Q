terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token  =  "<tocken>"
  cloud_id  = "<cloud id>"
  folder_id = "<folder id>"
}