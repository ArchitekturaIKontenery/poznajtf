# Ćwiczenie 6.2 - Niestandardowe warunki walidacji
## Opis
W ramach tego ćwiczenia nauczysz się w jaki sposób możemy określać niestandardowe warunki walidacji parametrów wejściowych a także pre/post-conditions.

## Wykonanie ćwiczenia
Do wykonania ćwiczenia będziemy potrzebować podstawowe definicji zasobu. Utwórz plik `resources.tf` a następnie umieść w nim następującą zawartość:
```
resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World!"
}
```
Wykonaj następnie operację `apply` aby utworzyć lokalny plik.

## Dodanie parametru z walidacją
Spróbujmy dodać teraz parametr `filename`, w ramach którego dodamy warunek z walidacją. Utwórz plik `variables.tf` a następnie umieść w nim poniższy kod:
```
variable "filename" {
  type        = string
  description = "Name of a file to create."

  validation {
    condition     = length(var.filename) > 4 && substr(var.filename, 0, 4) == "ptf-"
    error_message = "The filename value must begin with \"ptf-\"."
  }
}
```
Zmodyfikuj także definicję samego lokalnego pliku:
```
resource "local_file" "file" {
  filename = var.filename
  content  = "Hello, World!"
}
```
Wykonaj następnię operację `apply` aby wprowadzić zmiany. Tym razem Terraform poprosi Ciebie o podanie nazwy pliku. W momencie, kiedy wprowadzimy nazwę niezgodną z warunkiem naszego walidatora, operacja zostanie przerwana:
```
Name of a file to create.

  Enter a value: tojesttest

╷
│ Error: Invalid value for variable
│
│   on variables.tf line 1:
│    1: variable "filename" {
│     ├────────────────
│     │ var.filename is "tojesttest"
│
│ The filename value must begin with "ptf-".
│
│ This was checked by the validation rule at variables.tf:5,3-13.
```
Podanie natomiast nazwy, która zaczyna się od `ptf-` pozwoli nam na kontynuowanie operacji:
```
var.filename
  Name of a file to create.

  Enter a value: ptf-exercise

local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.file must be replaced
-/+ resource "local_file" "file" {
      ~ content_base64sha256 = "3/1gIbsr1bCvZ2KQgJ7DpTGR3YHH9wpLKGiKNiGCmG8=" -> (known after apply)
      ~ content_base64sha512 = "N015SpXNz9izWZMYX++bo2jxYNja9DLQi6nx7R5avmzGkpHg+i/gAGpSVw7xjBne9OYXwzzlLvCm5fvjGMsDhw==" -> (known after apply)
      ~ content_md5          = "65a8e27d8879283831b664bd8b7f0ad4" -> (known after apply)
      ~ content_sha1         = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> (known after apply)
      ~ content_sha256       = "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f" -> (known after apply)
      ~ content_sha512       = "374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387" -> (known after apply)
      ~ filename             = "file.txt" -> "ptf-exercise" # forces replacement
      ~ id                   = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> (known after apply)
        # (3 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.file: Destroying... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file: Destruction complete after 0s
local_file.file: Creating...
local_file.file: Creation complete after 0s [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```
W ramach bloku `validation` możemy stosować dowolny warunek logiczny, który wykorzystuje wbudowane funkcje Terraform. Zobaczmy teraz w jaki sposób możemy wykorzystać pre/post-conditions.

## Pre/post-conditions
Wykorzystanie bloku `validation` to jedna z kilku warstw walidacji, które możemy wykorzystać w ramach pisania kodu Terraform. Aby dodatkowo zagwarantować, że zarządzany zasób jest utworzony w określonym stanie, wykorzystamy bloki `preconditions` oraz `postconditions`. Zacznijmy od pierwszego z nich - wprowadź nowy parametr wejściowy w pliku `variables.tf`
```
variable "is_secret" {
  type        = bool
  description = "Whether the file should be secret or not."
  default = false
}
```
Zmodyfikuj następnie definicję naszego zasobu:
```
resource "local_file" "file" {
  filename = var.filename
  content  = "Hello, World!"

  lifecycle {
    precondition {
      condition = var.is_secret == false
        error_message = "The file cannot be secret - use local_sensitive_file instead."
    }
  }
}
```
Wykonaj następnie operację `apply -var=filename=ptf-exercise -var=is_secret=true`:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
╷
│ Error: Resource precondition failed
│
│   on resources.tf line 7, in resource "local_file" "file":
│    7:       condition = var.is_secret == false
│     ├────────────────
│     │ var.is_secret is true
│
│ The file cannot be secret - use local_sensitive_file instead.
╵
```
Jak widzisz, Terraform blokuje wprowadzenie zmian ponieważ `precondition` nie jest spełnione. Pojawia się teraz pytanie kiedy tak naprawdę korzystać z tego bloku, gdyż równie dobrze wprowadzony warunek logiczny moglibyśmy zastosować na poziomie parametru wejściowego. Zastosowanie tego bloku może być miejscami faktycznie dość sytuacyjne, jednak tak naprawdę sekretem jest moment ewaluacji tego bloku. `precondition` wykonywane jest po wykonaniu każdej iteracji w pętlach `count` oraz `for_each`. W tym celu wprowadź zmiany w pliku `variables.tf`
```
variable "files" {
  type = map(object({
    filename  = string
    is_secret = bool
  }))
  description = "List of files to create."
}

variable "filename" {
  type        = string
  description = "Name of a file to create."

  validation {
    condition     = length(var.filename) > 4 && substr(var.filename, 0, 4) == "ptf-"
    error_message = "The filename value must begin with \"ptf-\"."
  }
}

variable "is_secret" {
  type        = bool
  description = "Whether the file should be secret or not."
  default = false
}
```
Następnie umieść nową konfigurację w pliku `resources.tf`:
```
resource "local_file" "file" {
  filename = var.filename
  content  = "Hello, World!"

  lifecycle {
    precondition {
      condition = var.is_secret == false
      error_message = "The file cannot be secret - use local_sensitive_file instead"
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
```
Na sam koniec dodaj plik `terraform.tfvars` w swoim katalogu roboczym:
```
files = {
  file1 = {
    filename = "value1.txt"
    is_secret = false
  }
  file2 = {
    filename = "value2.txt"
    is_secret = false
  }
}
```
W tym momencie jeśli wykonamy operację `apply -var=filename=ptf-exercise -var=is_secret=true` Terraform będzie chciał utworzyć kilka nowych plików lokalnych. Pozwól mu na to:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.file must be replaced
-/+ resource "local_file" "file" {
      ~ content_base64sha256 = "3/1gIbsr1bCvZ2KQgJ7DpTGR3YHH9wpLKGiKNiGCmG8=" -> (known after apply)
      ~ content_base64sha512 = "N015SpXNz9izWZMYX++bo2jxYNja9DLQi6nx7R5avmzGkpHg+i/gAGpSVw7xjBne9OYXwzzlLvCm5fvjGMsDhw==" -> (known after apply)
      ~ content_md5          = "65a8e27d8879283831b664bd8b7f0ad4" -> (known after apply)
      ~ content_sha1         = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> (known after apply)
      ~ content_sha256       = "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f" -> (known after apply)
      ~ content_sha512       = "374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387" -> (known after apply)
      ~ filename             = "ptf-exercise" -> "ptf-reserved.txt" # forces replacement
      ~ id                   = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> (known after apply)
        # (3 unchanged attributes hidden)
    }

  # local_file.file_from_loop["file1"] will be created
  + resource "local_file" "file_from_loop" {
      + content              = "Hello, World!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "value1.txt"
      + id                   = (known after apply)
    }

  # local_file.file_from_loop["file2"] will be created
  + resource "local_file" "file_from_loop" {
      + content              = "Hello, World!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "value2.txt"
      + id                   = (known after apply)
    }

Plan: 3 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.file: Destroying... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file: Destruction complete after 0s
local_file.file_from_loop["file2"]: Creating...
local_file.file_from_loop["file1"]: Creating...
local_file.file_from_loop["file2"]: Creation complete after 0s [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file_from_loop["file1"]: Creation complete after 0s [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file: Creating...
local_file.file: Creation complete after 0s [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Apply complete! Resources: 3 added, 0 changed, 1 destroyed.
```
Teraz wprowadź małą zmianę w pliku `terraform.tfvars` zmieniając np. wartość parametru `is_secret` jednego z plików na `true`:
```
files = {
  file1 = {
    filename = "value1.txt"
    is_secret = false
  }
  file2 = {
    filename = "value2.txt"
    is_secret = true
  }
}
```
Wykonanie operacji `apply` tym razem się nie powiedzie:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file_from_loop["file2"]: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file_from_loop["file1"]: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
╷
│ Error: Resource precondition failed
│
│   on resources.tf line 21, in resource "local_file" "file_from_loop":
│   21:       condition = each.value.is_secret == false && each.value.filename != "ptf-reserved.txt"
│     ├────────────────
│     │ each.value.filename is "value2.txt"
│     │ each.value.is_secret is true
│
│ The file cannot be secret - use local_sensitive_file instead. Also, the filename cannot be "ptf-reserved.txt".
╵
```
Widzimy jednak, że Terraform przeprowadza ewaluację warunku dla każdego pliku oddzielnie, co pozwala nam znacznie lepiej walidować kolekcje niż w standardowej formie walidacji parametru wejściowego.

## Post-conditions
Blok `postcondition`, w przeciwieństwie do `precondition` ma jedną przewagę - może uzyskać dostęp do obiektu zarządzanego obiektu za pomocą operatora `self`:
```
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
```
W sytuacji kiedy wykonasz teraz operację `apply -var=filename=ptf-special.txt -var=is_secret=false` zauważysz, że Terraform zgłosi błąd:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file_from_loop["file1"]: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
local_file.file_from_loop["file2"]: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]
╷
│ Error: Resource postcondition failed
│
│   on resources.tf line 16, in resource "local_file" "file":
│   16:         condition = length(self.content) > 0
│     ├────────────────
│     │ self.content is ""
│
│ The file content cannot be empty
```
Wynika on z faktu, że zawartość lokalnego pliku jest ustalana na podstawie ewaluacji warunku zmiennej lokalnej. Teoretycznie moglibyśmy wykonać tę walidację także w bloku `precondition`, pamiętaj jednak, że blok `postcondition` jest wykonany po zaaplikowaniu zmian na zasobie. Oznacza to, że np. jeśli utworzony plik lokalny nie miałby zawartości, chociażby w wyniku błędu, Terraform zgłosi nam błąd. Blok `precondition` pozwoliłby nam sprawdzić tylko i wyłącznie wartość zmiennej lokalnej.