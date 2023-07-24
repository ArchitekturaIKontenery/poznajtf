module "local_file" {
  source   = "./modules/local_file"
  for_each = var.files

  common = {
    filename        = each.value.filename
    file_permission = each.value.file_permission
  }

  content = {
    file_content      = each.value.content
    is_base64_content = each.value.is_base64_content
    is_sourced_file   = each.value.is_sourced_file
    file_source       = each.value.file_source
    is_secret         = each.value.is_secret
  }
}