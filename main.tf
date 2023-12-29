,,,

### Описание провайдера

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

### Токен YC

provider "yandex" {
  token     = "******************************"
  cloud_id  = "b1goh4vtmuj4fpo8gc0q"
  folder_id = "b1gjqdvni5q428vrpdii"
  zone      = "ru-central1-a"
}



### Виртуальные машины 

resource  "yandex_compute_instance" "vm-1" {
  count = 2

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd84ocs2qmrnto64cl6m"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

metadata = {
     ssh-keys = "ubuntu:${file("/home/sizik0ff/terraform1/terraformkey.pub")}"
  }  
}


### Настройки сети

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

### Настройки таргет группы 

resource "yandex_lb_target_group" "tg-1" {
  name      = "my-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    address   = "${yandex_compute_instance.vm-1[0].network_interface.0.ip_address}"
  }
target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    address   = "${yandex_compute_instance.vm-1[1].network_interface.0.ip_address}"
  }
}

### Добавление сетевого балансировщика

resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "my-network-load-balancer"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg-1.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

,,,
