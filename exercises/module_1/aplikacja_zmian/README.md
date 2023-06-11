# Ćwiczenie 1.4 - Aplikacja zmian
## Opis
W ramach tego ćwiczenia wprowadzimy zmiany do infrastruktury, które zweryfikowaliśmy w poprzednim ćwiczeniu.

## Wykonanie ćwiczenia
Aby wykonać to ćwiczenie wykonaj najpierw ćwiczenie `1.3 - Planowanie wdrożenia`. Następnie przejdź do opisanych poniżej kroków.

### Planowanie
Każdorazowo przed aplikacją zmian w Terraform wykonaj operację `plan`, która zweryfikuje lokalną konfigurację vs plik stanu:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.aplikacja_wdrozenia will be created
  + resource "local_file" "aplikacja_wdrozenia" {
      + content              = "Ćwiczenie 1.3 - Planowanie wdrożenia!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = (known after apply)
      + id                   = (known after apply)
    }

  # random_string.aplikacja_wdrozenia will be created
  + resource "random_string" "aplikacja_wdrozenia" {
      + id          = (known after apply)
      + length      = 8
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = true
      + numeric     = true
      + result      = (known after apply)
      + special     = true
      + upper       = true
    }

Plan: 2 to add, 0 to change, 0 to destroy

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
Jak widzisz, Terraform informuje nas o 2 zasobach, które zostaną utworzone jeśli zaaplikujemy zmiany. Po upewnieniu się, że prezentowana konfiguracja jest poprawna z naszego punktu widzenia, przejdźmy do kolejnego kroku.

### Aplikacja zmian
Do aplikacji zmian w Terraform wykorzystamy komendę `apply`. Komenda ta próbuje wprowadzić zmianę zdefiniowane w kodzie Terraform w kontekście docelowego środowiska naszej infrastruktury. Tego typu wdrożenie może oczywiście się nie udać z wielu powodów - w tej sytuacji Terraform zaraportuje odpowiedni błąd.

Wprowadźmy więc zmiany, które zostały zaraportowane za pomocą komendy `plan`:
```
terraform apply
```
Uruchomienie tej komendy ma następujące skutki:
* Terraform ponownie generuje plan wdrożenia
* Zmiany muszą być jawnie zaakceptowane przez nas poprzez podanie wartości **yes**
* Terraform tworzy dwa zasoby o typach `random_string` oraz `local_file`

Wynikiem działania komendy `apply` powinien być lokalny plik o losowo wygenerowanej nazwie, np. `O_:O>sx2.txt`. Zauważ jednak, że tego typu nazwa pliku może być niewłaściwa dla Twojego systemu operacyjnego. Objawem będzie utworzenie pustego pliku bez zdefiniowanego rozszerzenia. Spróbujmy naprawić tę sytuację.

### Generowanie poprawnej nazwy pliku
Jeśli rzucimy wzrokiem na dokumentację dla `random_string` (https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) możemy zauważyć, że posiada on parametr `special`, który określa czy specjalne znaki powinny być częścią generowanego łańcucha znaków. Spróbujmy ustawić jego wartość na `false`:
```
resource "random_string" "aplikacja_wdrozenia" {
  length  = "8"
  special = false
}
```
Następnie ponownie wykoujemy operację `apply`:
```
random_string.aplikacja_wdrozenia: Refreshing state... [id=O_:O>sx2]
local_file.aplikacja_wdrozenia: Refreshing state... [id=e5e11ec51b01de1340608157f5376058f031c0ce]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.aplikacja_wdrozenia will be created
  + resource "local_file" "aplikacja_wdrozenia" {
      + content              = "Ćwiczenie 1.3 - Planowanie wdrożenia!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = (known after apply)
      + id                   = (known after apply)
    }

  # random_string.aplikacja_wdrozenia must be replaced
-/+ resource "random_string" "aplikacja_wdrozenia" {
      ~ id          = "O_:O>sx2" -> (known after apply)
      ~ result      = "O_:O>sx2" -> (known after apply)
      ~ special     = true -> false # forces replacement
        # (9 unchanged attributes hidden)
    }

Plan: 2 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

random_string.aplikacja_wdrozenia: Destroying... [id=O_:O>sx2]
random_string.aplikacja_wdrozenia: Destruction complete after 0s
random_string.aplikacja_wdrozenia: Creating...
random_string.aplikacja_wdrozenia: Creation complete after 0s [id=9gW0dKvB]
local_file.aplikacja_wdrozenia: Creating...
local_file.aplikacja_wdrozenia: Creation complete after 0s [id=e5e11ec51b01de1340608157f5376058f031c0ce]

Apply complete! Resources: 2 added, 0 changed, 1 destroyed.
```
Wynikiem działania tej komendy będzie odtworzenie pliku wraz z jego zawartością. Zmianą, która wymusza odtworzenie pliku to ustawienie parameteru `special = false`, który wpływa na jego nazwę.