# Ćwiczenie 2.2 - Walidacja zmiennych
## Opis
W ramach tego ćwiczenia zdefiniujemy zmienne wejściowe i spróbujemy wprowadzić podstawową formę ich walidacji.

## Wykonanie ćwiczenia
Zanim zaczniemy pracować ze zmiennymi, zdefiniujmy pojedynczy zasób `local_file`:
```
resource "local_file" "walidacja_zmiennych" {
  filename = "file.txt"
  content  = "Ćwiczenie 2.2 - Walidacja zmiennych"
}
```
Umieść zasób w pliku `resources.tf` a następnie wykonaj operację `apply` aby pojawił się on w lokalnym katalogu.

### Zdefiniowanie zmiennej wejściowej
W przeciwieństwie do zmiennych lokalnych, zmienne wejściowe posiadają nieco bogatszy sposób opisu. Stwórz plik `variables.tf` a następnie umieść w nim poniższy kod:
```
variable "filename" {
  type        = string
  description = "Nazwa pliku"
  default     = "file.txt"
}
```
Po dodaniu tej zmiennej, wykorzystaj ją w ramach zasobu z lokalnym plikiem:
```
resource "local_file" "walidacja_zmiennych" {
  filename        = var.filename
  content         = "Ćwiczenie 2.2 - Walidacja zmiennych!"
}
```
Po wprowadzeniu tych zmian, zastostuj operację `apply`:
```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
Na ten moment nie powinniśmy widzieć żadnych modyfikacji na poziomie naszej infrastruktury.

### Przekazanie wartości zmiennej
Wykonanie operacji `apply` na ten moment nie spowodowało żadnych zmian ponieważ nasza zmienna ma wartość `default`, która jest zgodna z nazwą pliku istniejącą w pliku stanu. Zobaczmy co się stanie jeśli przekażemy inną wartość:
```
terraform apply -var=filename=module_2.txt
```
Wynikiem działania tej komendy będzie usunięcie starego oraz dodanie nowego pliku:
```
local_file.walidacja_zmiennych: Refreshing state... [id=93668a0ead4fbac80c122590752f16c13220d0b6]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.walidacja_zmiennych must be replaced
-/+ resource "local_file" "walidacja_zmiennych" {
      ~ content_base64sha256 = "i3ZSm2NZGSdxIinCaw01cJNJzdf9bJQiRGSPY2GfLKU=" -> (known after apply)
      ~ content_base64sha512 = "kJWxPiCw4Ox7DHa5aKUPXaWW6AMvJFqWGxpDJAvdAtqOQXEzIX/FZepRh3yD7NVEXfgID74exRpY3oamc9NAug==" -> (known after apply)
      ~ content_md5          = "c1b571a94aff6a307eecbfc605c0f2d0" -> (known after apply)
      ~ content_sha1         = "93668a0ead4fbac80c122590752f16c13220d0b6" -> (known after apply)
      ~ content_sha256       = "8b76529b63591927712229c26b0d35709349cdd7fd6c942244648f63619f2ca5" -> (known after apply)
      ~ content_sha512       = "9095b13e20b0e0ec7b0c76b968a50f5da596e8032f245a961b1a43240bdd02da8e417133217fc565ea51877c83ecd5445df8080fbe1ec51a58de86a673d340ba" -> (known after apply)
      ~ filename             = "file.txt" -> "'module_2.txt'" # forces replacement
      ~ id                   = "93668a0ead4fbac80c122590752f16c13220d0b6" -> (known after apply)
        # (3 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.walidacja_zmiennych: Destroying... [id=93668a0ead4fbac80c122590752f16c13220d0b6]
local_file.walidacja_zmiennych: Destruction complete after 0s
local_file.walidacja_zmiennych: Creating...
local_file.walidacja_zmiennych: Creation complete after 0s [id=93668a0ead4fbac80c122590752f16c13220d0b6]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```
Wartość tej zmiennej mogłaby być oczywiście też przekazana za pomocą pliku ze zmiennymi bądź zmiennych środowiskowych.

### Walidacja
Jeśli chcemy wprowadzić dodatkowe sprawdzenie dla naszej zmiennej, możemy dodać do jej definicji blok `validation`:
```
variable "filename" {
  type        = string
  description = "Nazwa pliku"
  default     = "file.txt"

  validation {
    condition     = length(var.filename) > 8
    error_message = "Nazwa pliku musi mieć więcej niż 8 znaków!"
  }

  validation {
    condition     = endswith(var.filename, ".txt")
    error_message = "Nazwa pliku musi kończyć się na .txt!"
  }
}
```
W tym momencie jeśli jakikolwiek z tych warunków nie zostanie spełniony, Terraform nie pozwoli nam wykonać wdrożenia:
```
terraform apply -var=filename=module_2.pdf

╷
│ Error: Invalid value for variable
│
│   on variables.tf line 1:
│    1: variable "filename" {
│     ├────────────────
│     │ var.filename is "module_2.txt2"
│
│ Nazwa pliku musi kończyć się na .txt!
│
│ This was checked by the validation rule at variables.tf:11,3-13.
╵
```
```
terraform apply -var=filename=a.txt

╷
│ Error: Invalid value for variable
│
│   on variables.tf line 1:
│    1: variable "filename" {
│     ├────────────────
│     │ var.filename is "a.txt"
│
│ Nazwa pliku musi mieć więcej niż 8 znaków!
│
│ This was checked by the validation rule at variables.tf:6,3-13.
╵
```
Reguły walidacji mogą być definiowane w dowolnej ilości a także wykorzystywać wbudowane funkcje Terraform.
