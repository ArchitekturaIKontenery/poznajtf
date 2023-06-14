locals {
  files = ["plik1.txt", "plik2.txt", "plik3.txt"]
}

resource "local_file" "file" {
  count = length(local.files)

  filename = local.files[count.index]
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${local.files[count.index]}"
}

locals {
  additional_files = {
    "file4.txt" = "file5.txt",
    "file5.txt" = "file4.txt"
  }
}

resource "local_file" "additional_file" {
  for_each = local.additional_files

  filename = each.key
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${each.value}"
}

locals {
  transformed_names = [for name in local.files : upper(name)]
}

resource "local_file" "transformed_file" {
  count = length(local.files)

  filename = local.transformed_names[count.index]
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${local.transformed_names[count.index]}"
}