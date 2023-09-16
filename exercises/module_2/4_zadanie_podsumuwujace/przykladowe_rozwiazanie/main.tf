resource "local_file" "file_count" {
  count = length(var.files)

  filename = "${var.files[count.index].name}-count.txt"
  content  = var.files[count.index].content
}

resource "local_file" "file_foreach" {
  for_each = { for file in var.files : file.name => file }

  filename = "${each.value.name}-foreach.txt"
  content  = each.value.content
}