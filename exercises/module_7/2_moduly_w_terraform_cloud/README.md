# Ćwiczenie 7.2 - Moduły Terraform Cloud
## Opis
W ramach tego ćwiczenia nauczysz się w jaki sposób pracować z modułami w Terraform Cloud.

## Wykonanie ćwiczenia
Aby zaczać pracę z modułami, upewnij się, że posiadasz konto w Terraform Cloud. Potrzebny będzie nam także workspace skonfigurowany w oparciu o system kontroli wersji. W razie wątpliwości, sprawdź ćwiczenie 7.1 gdzie wykonaliśmy całą początkową konfigurację.

## Terraform Registry
Moduły, które będziemy tworzyć oraz udostępniać, znajdować się będą w Terraform Registry (https://app.terraform.io/app/<organization>/registry/private/modules). Jest to miejsce, które pozwala Ci na określenie nie tylko samych modułów, ale także wykorzystywanych providerów w ramach kodu Terraform zarządzanego na poziomie Terraform Cloud.

## Dodawanie modułu
Aby dodać moduł, przejdź na zakładkę Add Module (https://app.terraform.io/app/<organization>/registry/modules/add). Podobnie jak to miało miejsce w przypadku workspace, mamy tutaj możliwość zdefiniowania systemu kontroli wersji, który będzie przechowywał nasz moduł. Ponieważ na potrzeby workspace skonfigurowałem wcześniej integrację z GitHub, w przypadku modułu ten provider także będzie przeze mnie wykorzystany.

Aby móc dodać moduł do Terraform Cloud wymagane będzie dedykowane repozytorium, w którym będziemy go przechowywać. Na potrzeby tego ćwiczenia wykorzystam moduł `local_file` z ćwiczenia 6.3. Po skopiowaniu zawartości modułu i pushu do repozytorium, wyszukaj repozytorium z modułem na widoku Add Module w Terraform Cloud. Po potwierdzeniu, że wszystko się zgadza, kliknij na przycisk **Publish module**.

## Brakujący tag
Po dodaniu modułu do Terraform Cloud zapewne zobaczysz następujący błąd:
```
Module source repository has no tags.
The source repository for the module "local-file" for provider "terraform" has no tags and therefore failed to setup. Please read the documentation on creating modules.

To resolve this issue, you can create a version by pushing a tag in the proper format. If the module was added in error, you can also delete it by clicking the "Delete Module" button in the top-right corner.
```
Aby go naprawić musimy dodać tag do naszego repozytorium z modułem. Możesz to zrobić np. z poziomu CLI na swoim komputerze:
```
git tag 1.0.0
git push origin 1.0.0
```
> Terraform Cloud wymaga aby wersjonowanie modułu było zgodne z założonym formatem - `x.y.z`

W sytuacji w której Terraform Cloud nie wykrywa dodanego tagu (który posiada odpowiedni format), usuń dodany moduł i dodaj go ponownie. 

## Overview modułu
Dodany moduł powinien być dostępny w Twoim registry (https://app.terraform.io/app/<organization>/registry/modules/private/<organization>/local-file/terraform/1.0.0 - zakładając, że wszystkie operacje z tego ćwiczenia zostały wykonane bez zmian). W ramach registry dostajemy dostęp do pełnego przeglądu modułu:
* README
* statystyki
* sposób użycia
* parametry wejściowe
* parametry wyjściowe
* zdefiniowane zasoby

Pozwala to na szybkie zrozumienie w jaki sposób możemy skorzystać z tego modułu.

## Wykorzystanie modułu
Aby wykorzystać moduł może być wymagane skonfigurowanie odpowiedniego dostępu do naszego registry (w przypadku wykorzystania Terraform CLI):
```
credentials "app.terraform.io" {
  token = "xxxxxx.atlasv1.zzzzzzzzzzzzz"
}
```
Token może być pozyskany w następującym miejscu - https://app.terraform.io/app/settings/tokens.

Jeśli jednak chcesz wykorzystać moduł w ramach workspace opartego o system kontroli wersji, moduł nie będzie wymagać dodatkowych poświadczeń. Przykładowo, jeśli wykorzystam kod z ćwiczenia 6.3 i dodam do repozytorium z konfiguracją mojej infrastruktury dodanego w ćwiczeniu 7.1, uzyskam następujący kod:
```
module "local-file" {
  source  = "app.terraform.io/PoznajTerraformExercise/local-file/terraform"
  version = "1.0.0"

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
Wykonanie operacji `git commit` oraz `git push` spowoduje, że mój workspace wykona operacje `plan` oraz opcjonalnie `apply` zgodnie z nową konfiguracją - wykorzystując moduł z mojego registry:
```
Terraform v1.5.3
on linux_amd64
Initializing plugins and modules...
{"@level":"info","@message":"Terraform 1.5.3","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:21.741253Z","terraform":"1.5.3","type":"version","ui":"1.1"}
{"@level":"info","@message":"local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:22.479812Z","hook":{"resource":{"addr":"local_file.file","module":"","resource":"local_file.file","implied_provider":"local","resource_type":"local_file","resource_name":"file","resource_key":null},"id_key":"id","id_value":"0a0a9f2a6772942557ab5355d76af442f8f65e01"},"type":"refresh_start"}
{"@level":"info","@message":"local_file.file: Refresh complete","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:22.483496Z","hook":{"resource":{"addr":"local_file.file","module":"","resource":"local_file.file","implied_provider":"local","resource_type":"local_file","resource_name":"file","resource_key":null}},"type":"refresh_complete"}
{"@level":"info","@message":"local_file.file: Drift detected (delete)","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:22.498260Z","change":{"resource":{"addr":"local_file.file","module":"","resource":"local_file.file","implied_provider":"local","resource_type":"local_file","resource_name":"file","resource_key":null},"action":"delete"},"type":"resource_drift"}
{"@level":"info","@message":"module.local-file[\"file1\"].local_file.file_base64[0]: Plan to create","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:22.498330Z","change":{"resource":{"addr":"module.local-file[\"file1\"].local_file.file_base64[0]","module":"module.local-file[\"file1\"]","resource":"local_file.file_base64[0]","implied_provider":"local","resource_type":"local_file","resource_name":"file_base64","resource_key":0},"action":"create"},"type":"planned_change"}
{"@level":"info","@message":"module.local-file[\"file2\"].local_file.file[0]: Plan to create","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:22.498381Z","change":{"resource":{"addr":"module.local-file[\"file2\"].local_file.file[0]","module":"module.local-file[\"file2\"]","resource":"local_file.file[0]","implied_provider":"local","resource_type":"local_file","resource_name":"file","resource_key":0},"action":"create"},"type":"planned_change"}
{"@level":"info","@message":"Plan: 2 to add, 0 to change, 0 to destroy.","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:22.498421Z","changes":{"add":2,"change":0,"import":0,"remove":0,"operation":"plan"},"type":"change_summary"}
{"@level":"warn","@message":"Warning: Value for undeclared variable","@module":"terraform.ui","@timestamp":"2023-07-25T10:44:22.498475Z","diagnostic":{"severity":"warning","summary":"Value for undeclared variable","detail":"The root module does not declare a variable named \"filename\" but a value was found in file \"/home/tfc-agent/.tfc-agent/component/terraform/runs/run-2JPPYoB3CJDeWV8L/terraform.tfvars\". If you meant to use this value, add a \"variable\" block to the configuration.\n\nTo silence these warnings, use TF_VAR_... environment variables to provide certain \"global\" settings to all configurations in your organization. To reduce the verbosity of these warnings, use the -compact-warnings option."},"type":"diagnostic"}

```
Oczywiście output operacji `plan` będzie zależeć od Twojej konfiguracji. W moim wypadku wykorzystałem plik `terraform.tfvars` z ćwiczenia 6.3, dzięki czemu Terraform od razu chce utworzyć dwa pliki lokalne.