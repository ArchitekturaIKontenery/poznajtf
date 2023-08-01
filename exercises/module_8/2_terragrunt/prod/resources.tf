resource "local_file" "file" {
  filename        = "file.txt"
  content         = "Hello, World!"
  file_permission = var.file_permissions
}