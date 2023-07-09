resource "local_file" "file" {
  content = jsonencode({
    "name" = "Terraform",
    "description" = "Przykładowy opis",
    "version" = "0.12.24"
  })
  filename = "local_file.json"
}