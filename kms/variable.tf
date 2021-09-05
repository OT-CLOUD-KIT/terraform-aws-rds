variable "alias_name" {
  description = "The name of the key alias"
  type        = string
}

variable "deletion_window_in_days" {
  description = "The duration in days after which the key is deleted after destruction of the resource"
  type        = string
  default     = 30
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "kms_policy" {
  description = "The policy of the key usage"
  type        = string
  default     = ""
}

