variable "zone" {
  default = "ru-central1-b"
  type    = string
}

variable "subnet" {
  default = "default-ru-central1-b"
  type    = string
}

variable "user" { default = "esjay" }

variable "public_key" {
  default = "~/.ssh/id_ed25519.pub"
  type = string
}