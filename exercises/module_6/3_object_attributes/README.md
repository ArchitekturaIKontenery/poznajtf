# Ćwiczenie 6.3 - Object attributes
## Opis
W ramach tego ćwiczenia nauczysz się w jaki sposób przeprowadzać refaktoryzację kodu z użyciem techniki `object attributes`.

## Wykonanie ćwiczenia
Aby zaczać ćwiczenie, utwórz w swoim katalogu roboczym katalog `modules`, w którym umieść katalog `local_file` wraz z plikiem `resources.tf` oraz poniższą zawartością:
```
resource "local_file" "file" {
  filename = var.filename
  content  = var.content
}
```
W katalogu `local_file` utwórz także plik `variables.tf` z definicjami parametrów wejściowych:
```
variable "filename" {
    type        = string
    description = "Name of a file to create."
    
    validation {
        condition     = length(var.filename) > 4 && substr(var.filename, 0, 4) == "ptf-"
        error_message = "The filename value must begin with \"ptf-\"."
    }
}

variable "content" {
    type        = string
    description = "Content of a file to create."
}
```
Na koniec w głównym katalogu roboczym utwórz kolejny plik `resources.tf`, gdzie znajdzie się odwołanie do modułu:
```
module "local_file" {
    source = "./modules/local_file"
    for_each = var.files

    filename = each.value.filename
    content  = each.value.content
}
```
Dodaj także plik `variables.tf` z następującą zawartością:
```
variable "files" {
    type = map(object({
        filename  = string
        content = string
    }))
    description = "List of files to create."  
}
```
Na koniec utwórz plik `terraform.tfvars`:
```
files = {
  file1 = {
    filename = "ptf-value1.txt"
    content = "content1"
  }
  file2 = {
    filename = "ptf-value2.txt"
    content = "content2"
  }
}
```
Następnie zaaplikuj zmiany za pomocą operacji `apply`.

## Rozbudowywanie modułu
Obecny interfejs naszego modułu `local_file` składa się obecnie z dwóch parametrów - `filename` oraz `content`. Dodajmy do niego kilka dodatkowych właściwości - najpierw zdefiniujmy dodatkowe właściwości w pliku `resources.tf` naszego modułu:
```
locals {
  content_base64 = base64encode(var.content)
}

resource "local_file" "file" {
  count = var.is_base64_content || var.is_sourced_file ? 0 : 1

  filename        = var.filename
  content         = var.content
  file_permission = var.file_permission
}

resource "local_file" "file_base64" {
  count = var.is_base64_content ? 1 : 0

  filename        = var.filename
  content_base64  = local.content_base64
  file_permission = var.file_permission
}

resource "local_file" "file_sourced" {
  count = var.is_sourced_file ? 1 : 0

  filename        = var.filename
  file_permission = var.file_permission
  source          = var.file_source
}
```
Następnie dodajmy definicje dla naszych parametrów:
```
variable "filename" {
  type        = string
  description = "Name of a file to create."

  validation {
    condition     = length(var.filename) > 4 && substr(var.filename, 0, 4) == "ptf-"
    error_message = "The filename value must begin with \"ptf-\"."
  }
}

variable "content" {
  type        = string
  description = "Content of a file to create."
}

variable "is_base64_content" {
  type        = bool
  description = "Whether the content is base64 encoded or not."
}

variable "file_permission" {
  type        = number
  description = "File permission."
}

variable "is_sourced_file" {
  type        = bool
  description = "Whether the file is sourced or not."
}

variable "file_source" {
  type        = string
  description = "Source of a file to create."
}

variable "is_secret" {
  type = bool
  description = "Whether the file is secret or not."

  validation {
    condition     = var.is_secret == false
    error_message = "You cannot create a secret file with this module. Use `sensitive_file` module instead."
  }
}
```
Na koniec zmodyfikujemy odwołanie do naszego modułu:
```
module "local_file" {
  source   = "./modules/local_file"
  for_each = var.files

  filename          = each.value.filename
  content           = each.value.content
  is_base64_content = each.value.is_base64_content
  file_permission   = each.value.file_permission
  is_sourced_file   = each.value.is_sourced_file
  file_source       = each.value.file_source
  is_secret         = each.value.is_secret
}
```
Wprowadź także stosowne zmiany do zmiennej `files` a także uzupełnij brakujące dane w pliku `terraform.tfvars`:
```
files = {
  file1 = {
    filename          = "ptf-value1.txt"
    content           = "content1"
    is_base64_content = true
    file_permission   = "0644"
    is_sourced_file   = false
    is_secret         = false
    file_source       = null
  }
  file2 = {
    filename          = "ptf-value2.txt"
    content           = "content2"
    is_base64_content = false
    file_permission   = "0644"
    is_sourced_file   = false
    is_secret         = false
    file_source       = null
  }
}
```
Zwróć uwagę, że obecna definicja modułu może być nieco trudna do odczytania - pod spodem nasz moduł operuje tak naprawdę na 3 różnych zasobach, które można by było od siebie odizolować także na poziomie interfejsu modułu. Zobaczmny w jaki sposób zrobić to z użyciem `object attributes`.

## Object attributes
Nasz moduł `local_file` składa się tak naprawdę z trzech elementów:
* zwykły plik lokalny
* plik lokalny zapisany jako base64
* plik tworzony na podstawie innego pliku

Możemy w takim razie wprowadził małą zmianę do interfejsu modułu:
```
variable "common" {
  type = object({
    filename        = string
    file_permission = string
  })
  description = "Common attributes for all files."

  validation {
    condition     = length(var.common.filename) > 4 && substr(var.common.filename, 0, 4) == "ptf-"
    error_message = "The filename value must begin with \"ptf-\"."
  }
}

variable "content" {
  type = object({
    file_content      = string
    is_base64_content = bool
    is_sourced_file   = bool
    file_source       = string
    is_secret         = bool
  })
  description = "Content of a file to create."

  validation {
    condition     = var.content.is_secret == false
    error_message = "You cannot create a secret file with this module. Use `sensitive_file` module instead."
  }
}
```
W tym momencie wywołanie tego modułu będzie miało następującą postać:
```
module "local_file" {
  source   = "./modules/local_file"
  for_each = var.files

  common = {
    filename        = each.value.filename
    file_permission = each.value.file_permission
  }

  content = {
    file_content      = each.value.content
    is_base64_content = each.value.is_base64_content
    is_sourced_file   = each.value.is_sourced_file
    file_source       = each.value.file_source
    is_secret         = each.value.is_secret
  }
}
```
Zauważ, że parametry zostały teraz pogrupowane w logiczne obiekty, które ułatwiają zarówno zrozumienie funkcjonalności modułu, jak i jego składowym. W ten sposób możesz pracować ze swoimi modułami, dzięki czemu ich użytkownicy będą w stanie znacznie łatwiej z nich korzystać.