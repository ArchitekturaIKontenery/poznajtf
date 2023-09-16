variable "files" {
  type = list(object({
    name    = string
    content = string
  }))
}