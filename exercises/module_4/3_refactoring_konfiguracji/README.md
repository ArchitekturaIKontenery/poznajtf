# Ćwiczenie 4.3 - Refactoring konfiguracji
## Opis
W ramach tego ćwiczenia zobaczymy w jaki sposób można pracować z kodem Terraform, w ramach którego zmieniamy identyfikatory. Ćwiczenie to jest jednym z kilku ćwiczeń, które skupiają się na refaktorowaniu kodu - kolejne pojawią się w następnych modułach.

## Wykonanie ćwiczenia
Zaczniemy od zdefiniowania pojedynczego zasobu w następujący sposób (plik `resources.tf`):
```
resource "local_file" "flie" {
  filename = "file.txt"
  content  = "Hello, World!"
}
```
Wykonaj następnie operację `apply`, która wprowadzi stosowne zmiany:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.flie will be created
  + resource "local_file" "flie" {
      + content              = "Hello, World!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "file.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
local_file.flie: Creating...
local_file.flie: Creation complete after 0s [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
Zauważ jednocześnie, że identyfikator zasobu `local_file` ma literówkę - zamiast `file` nazwaliśmy go `flie`. Spróbujmy naprawić ten błąd.

## Zmiana identyfikatora
Zmień konfigurację zasobu `local_file` tak aby posiadał poprawny identyfikator:
```
resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World!"
}
```
Następnie wykonaj operację `plan`:
```
local_file.flie: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = "Hello, World!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "file.txt"
      + id                   = (known after apply)
    }

  # local_file.flie will be destroyed
  # (because local_file.flie is not in configuration)
  - resource "local_file" "flie" {
      - content              = "Hello, World!" -> null
      - content_base64sha256 = "3/1gIbsr1bCvZ2KQgJ7DpTGR3YHH9wpLKGiKNiGCmG8=" -> null
      - content_base64sha512 = "N015SpXNz9izWZMYX++bo2jxYNja9DLQi6nx7R5avmzGkpHg+i/gAGpSVw7xjBne9OYXwzzlLvCm5fvjGMsDhw==" -> null
      - content_md5          = "65a8e27d8879283831b664bd8b7f0ad4" -> null
      - content_sha1         = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> null
      - content_sha256       = "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f" -> null
      - content_sha512       = "374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = "file.txt" -> null
      - id                   = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> null
    }

Plan: 1 to add, 0 to change, 1 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Okazuje się, że mamy problem. Terraform, w momencie kiedy zmieniliśmy identyfikator, traktuje nasz zasób tak jakby nigdy nie istniał - w momencie kiedy wykonamy operację `apply`, lokalny plik zostałby usunięty a następnie utworzony ponownie. Co więcej, nie mamy pomiędzy nimi żadnej zależności - w najgorszym wypadku Terraform będzie próbować utworzyć nowy plik w miejsce tego, który nadal istnieje. Dla `local_file` nie jest to duży problem, jednak dla niektórych zasobów (np. w chmurowych) tego typu operacja na ogół zakończy sie błędem. W jaki sposób możemy więc wskazać Terraform, że tak naprawdę to jest cały czas ten sam zasób?

## Blok `moved`
Do przeprowadzenia tego typu operacji (rename / refactor) wykorzystamy blok `moved`:
```
moved {
  from = local_file.flie
  to   = local_file.file
}
```
Blok ten wskazuje Terraform, że zmieniamy identyfikator zasobu z `flie` na `file`. Pozostałe wartości powinny pozostać bez zmian. Wykonaj teraz operację `plan`:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Terraform will perform the following actions:

  # local_file.flie has moved to local_file.file
    resource "local_file" "file" {
        id                   = "0a0a9f2a6772942557ab5355d76af442f8f65e01"
        # (10 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Sukces! Terraform po zaaplikowaniu tej zmiany zmieni wewnętrzny identyfikator, dzięki czemu będziemy mogli nadal pracować z zasobem. Wykonaj operację `apply` aby poprawić konfigurację:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Terraform will perform the following actions:

  # local_file.flie has moved to local_file.file
    resource "local_file" "file" {
        id                   = "0a0a9f2a6772942557ab5355d76af442f8f65e01"
        # (10 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
Od tego momentu nasz zasób będzie posiadał poprawny identyfikator.

## Usunięcie bloku `moved`
W momencie kiedy nie wszyscy zaaplikowali stosowną zmianę (tj. pobrali najnowszą wersję kodu i uaktualnili swój plik stanu), blok `moved` może zostać usunięty. Spróbuj wykonać to w ramach swojej konfiguracji a następnie wykonaj operację `plan`:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
Wszystko działa tak jak tego oczekiwaliśmy. Pamiętaj jednak, że tego typu zmiana (usunięcie bloku `moved`) może być wykonanana dopiero **po tym** jak wszędzie plik stanu został uaktualniony. Zrobienie tego wcześniej może skutkować usunięciem zdefiniowanego zasobu, dlatego też najbezpieczniej jest wykonywać taką operację dopiero po czasie wygaszania starej konfiguracji.