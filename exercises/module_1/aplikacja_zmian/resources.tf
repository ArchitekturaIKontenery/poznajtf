resource "random_string" "aplikacja_wdrozenia" {
  length  = "8"
  special = false
}

resource "local_file" "aplikacja_wdrozenia" {
  filename = "${random_string.aplikacja_wdrozenia.result}.txt"
  content  = "Ćwiczenie 1.3 - Planowanie wdrożenia!"
}