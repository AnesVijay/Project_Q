data "yandex_vpc_subnet" "default-subnet" {
  name = var.subnet
}

data "yandex_compute_image" "ubuntu-2204-latest" {
  family = "ubuntu-2204-lts"
}



resource "yandex_compute_instance" "gitlab" {
  name        = "gitlab"
  zone        = var.zone

  resources {
    core_fraction = 100
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2204-latest.id
      size = 15
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default-subnet.id
    ipv6      = false
    nat       = true
  }

  metadata = {
    user-data = "${file("vm-ssh-init.yml")}"
  }
}

# resource "yandex_compute_instance" "coders" {
#   name        = "coders"
#   zone        = var.zone

#   resources {
#     core_fraction = 5
#     cores  = 2
#     memory = 2
#   }

#   boot_disk {
#     initialize_params {
#       image_id = data.yandex_compute_image.ubuntu-2204-latest.id
#       size = 8
#     }
#   }

#   network_interface {
#     subnet_id = data.yandex_vpc_subnet.default-subnet.id
#     ipv6      = false
#     nat       = true
#   }

#   metadata = {
#     user-data = "${file("vm-ssh-init.yml")}"
#   }
# }

resource "yandex_compute_instance" "monitor" {
  name        = "monitor"
  zone        = var.zone

  resources {
    core_fraction = 5
    cores  = 2
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2204-latest.id
      size = 20
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default-subnet.id
    ipv6      = false
    nat       = true
  }

  metadata = {
    user-data = "${file("vm-ssh-init.yml")}"
  }
}

resource "yandex_compute_instance" "prod" {
  name        = "prod"
  zone        = var.zone

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2204-latest.id
      size = 8
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default-subnet.id
    ipv6      = false
    nat       = true
  }

  metadata = {
    user-data = "${file("vm-ssh-init.yml")}"
  }
}



output "gitlab-server-ip" {
  value = yandex_compute_instance.gitlab.network_interface.0.nat_ip_address
}

# output "coders-server-ip" {
#   value = yandex_compute_instance.coders.network_interface.0.nat_ip_address
# }

output "monitor-server-ip" {
  value = yandex_compute_instance.monitor.network_interface.0.nat_ip_address
}

output "prod-server-ip" {
  value = yandex_compute_instance.prod.network_interface.0.nat_ip_address
}