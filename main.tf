resource "yandex_iam_service_account" "sa" {
  name = "storage-kms-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa_key" {
  service_account_id = yandex_iam_service_account.sa.id
}

resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-key"
  description       = "Key for Object Storage encryption"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

resource "yandex_kms_symmetric_key_iam_binding" "encrypter" {
  symmetric_key_id = yandex_kms_symmetric_key.bucket_key.id
  role             = "kms.keys.encrypterDecrypter"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}

resource "yandex_storage_bucket" "site" {
  bucket     = "victoria-luginina-site-20261021"
  acl        = "public-read"
  folder_id  = var.folder_id
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key

  anonymous_access_flags {
    read = true
    list = false
  }

  website {
    index_document = "index.html"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  depends_on = [yandex_kms_symmetric_key_iam_binding.encrypter]
}

resource "yandex_storage_object" "index" {
  bucket       = yandex_storage_bucket.site.bucket
  key          = "index.html"
  source       = "${path.module}/index.html"
  acl          = "public-read"
  content_type = "text/html"
  access_key   = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.sa_key.secret_key
}

resource "yandex_storage_bucket" "website" {
  bucket     = "victoria-luginina-web-20261021"
  acl        = "public-read"
  folder_id  = var.folder_id
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key

  anonymous_access_flags {
    read = true
    list = false
  }

  website {
    index_document = "index.html"
  }
}

resource "yandex_storage_object" "website_index" {
  bucket       = yandex_storage_bucket.website.bucket
  key          = "index.html"
  source       = "${path.module}/index.html"
  acl          = "public-read"
  content_type = "text/html"
  access_key   = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.sa_key.secret_key
}

output "website_url" {
  value = "http://${yandex_storage_bucket.website.bucket}.website.yandexcloud.net"
}

output "encrypted_bucket" {
  value = yandex_storage_bucket.site.bucket
}

output "kms_key_id" {
  value = yandex_kms_symmetric_key.bucket_key.id
}
