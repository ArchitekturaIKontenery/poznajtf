data "local_file" "file" {
  filename = "data.dat"
}

resource "local_file" "file" {
  filename = "new_data.dat"
  content  = data.local_file.file.content
}

data "local_sensitive_file" "file" {
  depends_on = [ local_file.file ]
  filename = "sensitive_data.dat"
}

resource "local_sensitive_file" "file" {
  filename = "new_sensitive_data.dat"
  content  = data.local_sensitive_file.file.content
}

locals {
  files = ["file1.txt", "file2.txt", "file3.txt"]
}

data "local_file" "loop_file" {
  for_each = toset(local.files)
  filename = "files/${each.value}"
}

resource "local_file" "loop_file" {
  for_each = toset(local.files)
  filename = "new_${each.value}"
  content  = data.local_file.loop_file[each.key].content
}