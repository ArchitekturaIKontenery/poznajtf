resource "local_file" "local_file" {
  count = var.is_sensitive ? 0 : 1

  content  = "Hello, World!"
  filename = "local_file.txt"
}

resource "local_sensitive_file" "local_sensitive_file" {
  count = var.is_sensitive ? 1 : 0

  content  = "Hello, World!"
  filename = "local_sensitive_file.txt"
}