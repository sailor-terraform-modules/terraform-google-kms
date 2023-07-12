resource "google_kms_key_ring" "gcp_kms_keyring" {
  name     = var.kms_keyring_name
  location = var.location_id
  project  = var.project_id
}

resource "google_kms_crypto_key" "gcp_kms_crypto_key" {
  for_each        = { for kms_crypto_key in var.kms_crypto_keys : kms_crypto_key.name => kms_crypto_key }
  name            = each.key
  key_ring        = google_kms_key_ring.gcp_kms_keyring.id
  labels          = each.value.labels
  rotation_period = each.value.rotation_period

  purpose = each.value.purpose

  dynamic "version_template" {
    for_each = each.value.set_version_template == true ? [1] : []
    content {
      algorithm        = each.value.algorithm
      protection_level = each.value.protection_level
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_key_ring_iam_binding" "kms_keyring_iam_binding" {
  for_each    = setunion(var.kms_keyring_members)
  key_ring_id = google_kms_key_ring.gcp_kms_keyring.id
  role        = "roles/cloudkms.admin"
  members     = each.value
}

resource "google_kms_crypto_key_iam_binding" "kms_key_iam_decrypter" {
  for_each      = { for kms_crypto_key in var.kms_crypto_keys : kms_crypto_key.name => kms_crypto_key }
  crypto_key_id = google_kms_crypto_key.gcp_kms_crypto_key[each.key].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members       = each.value.kms_key_members
}

data "google_project" "current" {
  project_id = var.project_id
}