resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World!"
}

# moved {
#   from = local_file.flie
#   to   = local_file.file
# }