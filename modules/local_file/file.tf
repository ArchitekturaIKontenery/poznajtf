resource "local_file" "local_file" {
  count = var.is_sensitive ? 0 : 1

  content  = var.content
  filename = var.filename
}

resource "local_sensitive_file" "local_sensitive_file" {
  count = var.is_sensitive ? 1 : 0

  content  = var.content
  filename = var.filename
}