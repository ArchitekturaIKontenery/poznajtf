variable "files" {
  type = map(object({
    filename  = string
    is_secret = bool
  }))
  description = "List of files to create."
}

variable "filename" {
  type        = string
  description = "Name of a file to create."

  validation {
    condition     = length(var.filename) > 4 && substr(var.filename, 0, 4) == "ptf-"
    error_message = "The filename value must begin with \"ptf-\"."
  }
}

variable "is_secret" {
  type        = bool
  description = "Whether the file should be secret or not."
  default = false
}
