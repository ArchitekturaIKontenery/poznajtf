locals {
  filename = "file.txt"
}

resource "local_file" "aplikacja_wdrozenia" {
  filename        = local.filename
  file_permission = local.file_permissions
  content         = "Ćwiczenie 2.1 - Używanie lokalnych zmiennych!"
}