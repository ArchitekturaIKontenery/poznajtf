variable "files" {
  type = map(object({
    filename          = string
    content           = string
    is_base64_content = bool
    file_permission   = string
    is_sourced_file   = bool
    file_source       = string
    is_secret         = bool
  }))
  description = "List of files to create."
}