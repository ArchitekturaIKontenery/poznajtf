# Ćwiczenie 4.1 - Tworzenie lokalnego modułu
## Opis
W ramach tego ćwiczenia zobaczymy w jaki sposób możemy wytworzyć lokalny moduł na podstawie poznanych wcześniej zasobów.

## Wykonanie ćwiczenia
Aby zacząć, stwórz plik `resources.tf` w którym znajdą się następujące dwa zasoby:
```
resource "local_file" "local_file" {
  content  = "Hello, World!"
  filename = "local_file.txt"
}

resource "local_sensitive_file" "local_sensitive_file" {
  content  = "Hello, World!"
  filename = "local_sensitive_file.txt"
}
```
Wyobraź sobie teraz, że chcemy przygotować funkcjonalność, która pozwoli innym osobom na tworzenie plików lokalnych, w zależności od przekazanej konfiguracji. Normalnie każda osoba bądź zespół musiałyby samodzielnie kodować tego typu funkcjonalność. Jeśli umieścimy ją w ramach modułu, z łatwością będziemy mogli ją współdzielić pomiędzy różnymi użytkownikami.

## Przygotowanie modułu
W swoim lokalnym katalogu roboczym przygotuj katalog `modules/local_file` a następnie utwórz w nim plik `file.tf`. Skopiuj do niego zawartość pliku `resources.tf`. 
> Nazwa `file.tf`, podobnie jak inne nazwy plików w Terraform, nie ma znaczenia z punktu widzenia pisania kodu Terraform. Jeśli chcesz, możesz wybrać dowolną inną.

Usuń teraz zawartość pliku `resources.tf` i zastąp ją poniższą definicją:
```
module "local_file" {
    source = "./modules/local_file"
}
```
Następnie wykonaj operację `plan`:
```
 Error: Module not installed
│
│   on resources.tf line 1:
│    1: module "local_file" {
│
│ This module is not yet installed. Run "terraform init" to install all modules required by this configuration.
```
Jak widzisz, w momencie kiedy zaczynamy wykorzystywać moduły, Terraform wymaga od nas zainicjalizowania konfiguracji. Wykonaj w takim razie operację `init:
```
Initializing modules...
- local_file in modules\local_file

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/local...
- Installing hashicorp/local v2.4.0...
- Installed hashicorp/local v2.4.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
Niezależnie od tego czy korzystamy z modułu lokalnego czy zdalnego, Terraform musi zapisać odpowiednią referencję do niego w swojej konfiguracji. Pozwala mu to potem śledzić zależności, dzięki czemu zmiany wersji modułów są dla niego widoczne.

Wykonaj ponownie operację `plan`. Tym razem wszystko zadziała poprawnie:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.local_file.local_file.local_file will be created
  + resource "local_file" "local_file" {
      + content              = "Hello, World!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "local_file.txt"
      + id                   = (known after apply)
    }

  # module.local_file.local_sensitive_file.local_sensitive_file will be created
  + resource "local_sensitive_file" "local_sensitive_file" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0700"
      + file_permission      = "0700"
      + filename             = "local_sensitive_file.txt"
      + id                   = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Dodajmy teraz do naszego modułu trochę logiki.

## Logika w module
Dodamy nową funkcjonalność do naszego modułu - jeśli użytkownik wskaże, że chce utworzyć plik "sensitive", nie będziemy tworzyć standardowego pliku, którego zawartość jest zawsze jawna. W tym celu dodaj plik `variables.tf` w katalogu swojego modułu z następującą zawartością:
```
variable "is_sensitive" {
  type    = bool
  default = false
}
```
Następnie wprowadź następującą zmianę w pliku `file.tf`:
```
resource "local_file" "local_file" {
  count = var.is_sensitive ? 0 : 1

  content  = "Hello, World!"
  filename = "local_file.txt"
}

resource "local_sensitive_file" "local_sensitive_file" {
  count = var.is_sensitive ? 1 : 0

  content  = "Hello, World!"
  filename = "local_sensitive_file.txt"
}
```
Jak widzisz, uzależnimy teraz określonego typu zasobu od zmiennej wejściowej. Aby dopełnić konfiguracji, zmienimy sposób wywołania modułu:
```
module "local_file" {
  source = "./modules/local_file"

  is_sensitive = true
}
```
Wykonajmy teraz operację `plan`:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.local_file.local_sensitive_file.local_sensitive_file[0] will be created
  + resource "local_sensitive_file" "local_sensitive_file" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0700"
      + file_permission      = "0700"
      + filename             = "local_sensitive_file.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Jak widzisz, tym razem tworzony jest tylko jeden plik - wybrany został typ `local_sensitive_file`. Spróbuj samodzielnie wykonać kilka poniższych zmian:
* użytkownik może ustawić w module parametr `content` oraz `filename`
* jeśli tworzymy plik "sensitive", powinien on być utworzony jako tylko do odczytu

## Output modułu
Dobrą praktyką jest zdefiniowanie informacji wyjściowych z modułu, dzięki czemu można integrować zasoby pomiędzy sobą. Dodaj plik `outputs.tf` w katalogu naszego modułu i zdefiniuj poniższe wartości:
```
output "id" {
    value = var.is_sensitive ? local_sensitive_file.local_sensitive_file[0].id : local_file.local_file[0].id
}
```
Zdefniuj też plik `outputs.tf` w ramach naszego katalogu roboczego:
```
output "file_id" {
  value = module.local_file.id
}
```
Wykonaj następnie operację `apply`:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.local_file.local_sensitive_file.local_sensitive_file[0] will be created
  + resource "local_sensitive_file" "local_sensitive_file" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0700"
      + file_permission      = "0700"
      + filename             = "local_sensitive_file.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + file_id = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.local_file.local_sensitive_file.local_sensitive_file[0]: Creating...
module.local_file.local_sensitive_file.local_sensitive_file[0]: Creation complete after 0s [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

file_id = "0a0a9f2a6772942557ab5355d76af442f8f65e01"
```
Jak widzisz, zwróciliśmy z naszego modułu identyfikator utworzonego pliku. Możemy w ten sposób zwrócić dowolną wartość (nawet wygenerowaną dynamicznie), dzięki czemu użytkownicy naszych modułów mogą je pobrać i wykorzystać w ramach własnego kodu.