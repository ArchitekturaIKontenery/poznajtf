locals {
  content_base64 = base64encode(var.content.file_content)
}

resource "local_file" "file" {
  count = var.content.is_base64_content || var.content.is_sourced_file ? 0 : 1

  filename        = var.common.filename
  content         = var.content.file_content
  file_permission = var.common.file_permission
}

resource "local_file" "file_base64" {
  count = var.content.is_base64_content ? 1 : 0

  filename        = var.common.filename
  content_base64  = local.content_base64
  file_permission = var.common.file_permission
}

resource "local_file" "file_sourced" {
  count = var.content.is_sourced_file ? 1 : 0

  filename        = var.common.filename
  file_permission = var.common.file_permission
  source          = var.content.file_source
}