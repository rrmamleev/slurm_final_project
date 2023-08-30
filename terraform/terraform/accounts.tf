resource "yandex_iam_service_account" "this" {
  description = "Service account for Kubernetes cluster"
  name        = "k8s-service-account"
}

# Assign "editor" role to service account.
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.YC_FOLDER_ID
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}"
  ]
}

# Assign "images-puller" role to service account.
resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = var.YC_FOLDER_ID
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}"
  ]
}
