resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World! - ${timestamp()}"
  file_permission = "0770"

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "local_file" "file2" {
  filename = "file2.txt"
  content  = "Hello, World! - ${timestamp()}"
  file_permission = "0777"

  lifecycle {
    create_before_destroy = true
  }
}

# resource "local_file" "file3" {
#   filename = "file3.txt"
#   content  = "Hello, World! - ${timestamp()}"
#   file_permission = "0600"

#   lifecycle {
#     prevent_destroy = true
#   }
# }