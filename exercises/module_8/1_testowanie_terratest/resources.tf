resource "local_file" "test" {
  filename = "test.txt"
  content  = "test"
}

output "filename" {
  value = local_file.test.filename
}