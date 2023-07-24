variable "common" {
  type = object({
    filename        = string
    file_permission = string
  })
  description = "Common attributes for all files."

  validation {
    condition     = length(var.common.filename) > 4 && substr(var.common.filename, 0, 4) == "ptf-"
    error_message = "The filename value must begin with \"ptf-\"."
  }
}

variable "content" {
  type = object({
    file_content      = string
    is_base64_content = bool
    is_sourced_file   = bool
    file_source       = string
    is_secret         = bool
  })
  description = "Content of a file to create."

  validation {
    condition     = var.content.is_secret == false
    error_message = "You cannot create a secret file with this module. Use `sensitive_file` module instead."
  }
}