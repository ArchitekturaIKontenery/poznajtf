# Ćwiczenie 2.1 - Używanie lokalnych zmiennych
## Opis
W ramach tego ćwiczenia zdefiniujemy i wykorzystamy lokalne zmienne.

## Wykonanie ćwiczenia
Zanim zaczniemy pracować ze zmiennymi, zdefiniujmy pojedynczy zasób `local_file`:
```
resource "local_file" "aplikacja_wdrozenia" {
  filename = "file.txt"
  content  = "Ćwiczenie 2.1 - Używanie lokalnych zmiennych!"
}
```
Umieść zasób w pliku `resources.tf` a następnie wykonaj operację `apply` aby pojawił się on w lokalnym katalogu.

### Zdefiniowanie lokalnej zmiennej
Do zdefiniowania zmiennych lokalnych wykorzystujemy blok `locals`. Umieść go w dowolnym miejscu w swoim kodzie Terraform:
```
locals {
  filename = "file.txt"
}
```

### Wykorzystanie zmiennej lokalnej
Zdefniowaną zmienną możemy teraz wykorzystać w ramach definicji zasobu z plikiem lokalnym. Aby tego dokonać wykorzystamy referencję do zmiennej poprzez prefix `local.`:
```
resource "local_file" "aplikacja_wdrozenia" {
  filename = local.filename
  content  = "Ćwiczenie 2.1 - Używanie lokalnych zmiennych!"
}
```
Na sam koniec zweryfikujmy poprawność naszej konfiguracji poprzez operację `apply`:
```
local_file.aplikacja_wdrozenia: Refreshing state... [id=483419cf2f455e80cb6496f48b440aed928320ae]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
Wynikiem działania komendy `apply` powinna byc informacja o braku jakichkolwiek zmian w naszej infrastrukturze.

### Kilka bloków `locals`
Terraform dopuszcza posiadanie kilku bloków `locals` w ramach tej samej konfiguracji. Aby tego dokonać dodaj plik `locals.tf` w swoim katalogu roboczym z następującą zawartością:
```
locals {
    file_permissions = "0644"
}
```
Następnie wykorzystaj nową zmienną w konfiguracji lokalnego pliku:
```
resource "local_file" "aplikacja_wdrozenia" {
  filename        = local.filename
  file_permission = local.file_permissions
  content         = "Ćwiczenie 2.1 - Używanie lokalnych zmiennych!"
}
```
Ponownie zweryfikujmy poprawność naszej konfiguracji operacją `apply`:
```
local_file.aplikacja_wdrozenia: Refreshing state... [id=483419cf2f455e80cb6496f48b440aed928320ae]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.aplikacja_wdrozenia must be replaced
-/+ resource "local_file" "aplikacja_wdrozenia" {
      ~ content_base64sha256 = "sB/73edDrJk+auAkNPG5lLsvNKIB511tNWrvZK9fZ0U=" -> (known after apply)
      ~ content_base64sha512 = "TPctctcO77n2K2GmXJkNLwArUFBXPXKDDzHwFKo0VUmQK+83IsxV448qYjcVAG+oRHIlWMpHZQx6JMvlrL4nAA==" -> (known after apply)
      ~ content_md5          = "3a436e30ac339f330c9f871a95da83c6" -> (known after apply)
      ~ content_sha1         = "483419cf2f455e80cb6496f48b440aed928320ae" -> (known after apply)
      ~ content_sha256       = "b01ffbdde743ac993e6ae02434f1b994bb2f34a201e75d6d356aef64af5f6745" -> (known after apply)
      ~ content_sha512       = "4cf72d72d70eefb9f62b61a65c990d2f002b5050573d72830f31f014aa345549902bef3722cc55e38f2a623715006fa844722558ca47650c7a24cbe5acbe2700" -> (known after apply)
      ~ file_permission      = "0777" -> "0644" # forces replacement
      ~ id                   = "483419cf2f455e80cb6496f48b440aed928320ae" -> (known after apply)
        # (3 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.aplikacja_wdrozenia: Destroying... [id=483419cf2f455e80cb6496f48b440aed928320ae]
local_file.aplikacja_wdrozenia: Destruction complete after 0s
local_file.aplikacja_wdrozenia: Creating...
local_file.aplikacja_wdrozenia: Creation complete after 0s [id=483419cf2f455e80cb6496f48b440aed928320ae]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```
Tym razem Terraform odtworzył nasz lokalny plik - wynika to z wprowadzonych zmian na poziomie zdefiniowanych uprawnień:
```
~ file_permission      = "0777" -> "0644" # forces replacement
```
Ponieważ jednak zawartość pliku zdefiniowana jest w ramach tej samej konfiguracji, tego typu operacja nie jest ryzykowna.