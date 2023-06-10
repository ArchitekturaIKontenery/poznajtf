resource "random_string" "planowanie_wdrozenia" {
  length = "8"
}

resource "local_file" "planowanie_wdrozenia" {
  filename = random_string.planowanie_wdrozenia.result
  content = "Ćwiczenie 1.3 - Planowanie wdrożenia"
}