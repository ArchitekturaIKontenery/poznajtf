locals {
  content = endswith(var.filename, "special.txt") ? "" : "Hello, Terraform!"
}

resource "local_file" "file" {
  filename = var.filename
  content  = local.content

  lifecycle {
    precondition {
      condition = var.is_secret == false
      error_message = "The file cannot be secret - use local_sensitive_file instead"
    }

    postcondition {
        condition = length(self.content) > 0
        error_message = "The file content cannot be empty"
    }
  }
}

resource "local_file" "file_from_loop" {
  for_each = tomap(var.files)

  filename = each.value.filename
  content  = "Hello, World!"

  lifecycle {
    precondition {
      condition = each.value.is_secret == false && each.value.filename != "ptf-reserved.txt"
        error_message = "The file cannot be secret - use local_sensitive_file instead. Also, the filename cannot be \"ptf-reserved.txt\"."
    }
  }
}