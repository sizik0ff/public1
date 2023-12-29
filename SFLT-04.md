# Домашнее задание к занятию «Отказоустойчивость в облаке»

### Цель задания

В результате выполнения этого задания вы научитесь:  
1. Конфигурировать отказоустойчивый кластер в облаке с использованием различных функций отказоустойчивости. 
2. Устанавливать сервисы из конфигурации инфраструктуры.

------

### Чеклист готовности к домашнему заданию

1. Создан аккаунт на YandexCloud.  
2. Создан новый OAuth-токен.  
3. Установлено программное обеспечение  Terraform.
   

## Задание 1 

Возьмите за основу [решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке»](https://github.com/netology-code/sdvps-homeworks/blob/main/7-03.md#задание-1).

1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:

- создаст 2 идентичные виртуальные машины. Используйте аргумент [count](https://www.terraform.io/docs/language/meta-arguments/count.html) для создания таких ресурсов;
- создаст [таргет-группу](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group). Поместите в неё созданные на шаге 1 виртуальные машины;
- создаст [сетевой балансировщик нагрузки](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer), который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин.

Рекомендуем изучить [документацию сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart) для того, чтобы было понятно, что вы сделали.

2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите:*

*1. Terraform Playbook.*

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

---

# Terraform Playbook

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


