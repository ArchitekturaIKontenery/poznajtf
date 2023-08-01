# Ćwiczenie 8.2 - Wykorzystanie Terragrunt
## Opis
W ramach tego ćwiczenia nauczysz się w jaki sposób pracować z narzędziem Terragrunt.

## Wykonanie ćwiczenia
Aby skorzystać z Terragrunt zainstaluj narzędzie zgodnie z instrukcjami na stronie https://terragrunt.gruntwork.io/docs/getting-started/install/.

## Wykorzystanie Terragrunt
Głównym zastosowaniem Terragrunt jest pisanie konfiguracji Terraform w takim sposób aby nie było konieczności jej powielania. Jest to szczególnie istotne w kontekście wykorzystania backendów:
```
terraform {
  backend "some_backend" {
    key1         = var.key1
    key2         = var.key2
  }
}
```
W sytuacji kiedy chcemy skonfigurować oddzielny backend dla różnych środowisk (np. dev / prod), musimy stworzyć oddzielne katalogi zawierające konfigurację:
```
# tf/dev/terraform.tf
terraform {
  backend "some_backend" {
    key1         = "dev_key1"
    key2         = "dev_key2"
  }
}

# tf/prod/terraform.tf
terraform {
  backend "some_backend" {
    key1         = "prod_key1"
    key2         = "prod_key2"
  }
}
```
Wynika to z ograniczeń Terraform, który nie pozwala na inicjalizację z użyciem zmiennych. Można co prawda korzystać z parametru `-backend-config` w ramach operacji `init`, jednak nie zawsze się on sprawdza i bywa problematyczny w wykorzystaniu. Rozwiązaniem może być wykorzystanie Terragrunt, który pozwala nam na generowanie odpowiedniej konfiguracji w zależności od naszych potrzeb. Aby zaprezentować ten koncept, stwórz plik `terragrunt.hcl` w swoim głównym katalogu z poniższą zawartością:
```
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}
```
Następnie utwórz dwa katalogi `dev` oraz `prod` i umieść w nich plik `terragrunt.hcl` z poniższym kodem:
```
include "root" {
  path = find_in_parent_folders()
}
```
Wejdź teraz do katalogu `dev` i wywołaj komendę `terragrunt apply`:
```
Initializing the backend...

Successfully configured the backend "local"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
Ponieważ nasza konfiguracja jest pusta, nie zobaczymy żadnego zasobu, który by się utworzył. Zauważ jednak, że Terragrunt stworzy plik `backend.tf` zawierający ustawienia naszego backendu.

## Wykorzystanie Terragrunt do przekazania zmiennych
Utwórz w obu katalogach `dev` oraz `prod` plik `resources.tf` w ramach którego dodaj następujący kod:
```
resource "local_file" "file" {
  filename        = "file.txt"
  content         = "Hello, World!"
  file_permission = var.file_permissions
}
```
Dodaj też plik `variables.tf` gdzie zdefiniujesz wymaganą zmienną:
```
variable "file_permissions" {
  type    = string
}
```
Na koniec w głównym katalogu stwórz plik `common.tfvars` i dodaj w nim następującą zawartość:
```
file_permissions = "0644"
```
Możemy teraz wykorzystać Terragrunt do automatycznego przekazania tej zmiennej poprzez modyfikację pliku `terragrunt.hcl`:
```
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
      "-var-file=../common.tfvars"
    ]
  }
}
```
Możemy teraz wykonać operację `terragrunt plan` na jednym z naszych środowisk:
```
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

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
      + file_permission      = "0644"
      + filename             = "file.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```
Jak widzisz, Terragrunt automatycznie aplikuje skonfigurowane przez nas zmienne do aplikacji `plan` - to samo stałoby się w sytuacji wykonywania operacji `apply`. Jak widzisz, Terragrunt może być wykorzystywany zarówno do generowania plików w locie (dzięki funkcji `generate`) jak i uproszczania konfiguracji poprzez zdefiniowanie w jednym miejscu chociażby zmiennych. Pełen opis wszystkich możliwości tego narzędzia znajdziesz tutaj - https://terragrunt.gruntwork.io/docs/#features.