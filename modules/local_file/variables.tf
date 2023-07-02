variable "is_sensitive" {
  type    = bool
  default = false
}

variable "content" {
  type    = string
  default = "This is a local file"
}

variable "filename" {
  type    = string
  default = "local_file.txt"
}