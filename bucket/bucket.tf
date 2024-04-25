// Создаю учетку SA
resource "yandex_iam_service_account" "sa-terraform" {
    name      = "sa-terraform"
}

// Раздаю гранты
resource "yandex_resourcemanager_folder_iam_member" "terraform-editor" {
    folder_id = var.folder_id
    role      = "editor"
    member    = "serviceAccount:${yandex_iam_service_account.sa-terraform.id}"
    depends_on = [yandex_iam_service_account.sa-terraform]
}

// Создаю ключи доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
    service_account_id = yandex_iam_service_account.sa-terraform.id
    description        = "static access key"
}

// Беру ключи для создания bucket
resource "yandex_storage_bucket" "netology-bucketx" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = "zatulik-netology-bucketz"
    acl    = "private"
    force_destroy = true
}

