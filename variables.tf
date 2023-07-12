//required variables
variable "kms_keyring_name" {
  description = "The resource name for the KeyRing."
  type        = string
}

variable "location_id" {
  description = "The location for the KeyRing. A full list of valid locations can be found by running gcloud kms locations list."
  type        = string

}

variable "kms_crypto_keys" {
  description = "The list of crypto keys and their configuration to be created."
  type = list(object({
    name                 = string,
    labels               = map(string),
    rotation_period      = string,
    purpose              = string,
    set_version_template = bool,
    algorithm            = string,
    protection_level     = string,
    kms_key_members      = list(string)
  }))
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
}

variable "kms_keyring_members" {
  description = "Identities that will be granted the privilege in role"
  type        = list(string)
  default     = []
}

