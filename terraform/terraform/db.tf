resource "yandex_mdb_postgresql_cluster" "this" {
  name                = "yelb-db-cluster"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.this.id
  deletion_protection = false
  depends_on = [
    yandex_iam_service_account.this,
    yandex_kubernetes_cluster.this
  ]

  config {
    version = 11
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-hdd"
      disk_size          = "10"
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 8
  }

  host {
    zone      = "ru-central1-a"
    name      = "yelb-db-1"
    subnet_id = yandex_vpc_subnet.this["ru-central1-a"].id
    assign_public_ip = false
  }

  host {
    zone      = "ru-central1-b"
    name      = "yelb-db-2"
    subnet_id = yandex_vpc_subnet.this["ru-central1-b"].id
    assign_public_ip = false
  }
  
}

resource "yandex_mdb_postgresql_database" "this" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = var.DB_NAME
  owner      = var.DB_USER
  depends_on = [
    yandex_mdb_postgresql_user.this
  ]
}

resource "yandex_mdb_postgresql_user" "this" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = var.DB_USER
  password   = var.DB_PASS
}
