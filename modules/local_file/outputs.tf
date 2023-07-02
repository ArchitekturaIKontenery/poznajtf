output "id" {
    value = var.is_sensitive ? local_sensitive_file.local_sensitive_file[0].id : local_file.local_file[0].id
}