# Ćwiczenie 1.3 - Planowanie wdrożenia
## Opis
W ramach tego ćwiczenia zobaczymy w jaki sposób możemy zobaczyć jak nasze zmiany wpłyną na środowisko uruchomieniowe naszej konfiguracji Terraform.

## Wykonanie ćwiczenia
Aby wykonać to ćwiczenie musimy zdefiniować prostą konfigurację wraz z co najmniej jednym zasobem. Na potrzeby nauki wykorzystamy dwa powiązane zasoby:
* generator losowych nazw
* lokalny plik tekstowy

Oba zasoby będą od siebie zależne, tj. generator losowych nazw pozwoli nam wygenerować nazwę pliku, a lokalny plik tekstowy będzie docelowym "wdrażanym" zasobem.

### Określanie providerów 
Rozpoczynamy pracę od zdefiniowana naszego providera. W tym celu stworzyłem plik `provider.tf` z następującą zawartością:
```
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "=3.5.1"
    }
  }
}
```
Po zdefiniowaniu providera zainicjalizuj go używając komendy `terraform init`.

### Określanie zasobów
Nasza konfiguracja składać się będzie z dwóch zasobów. Aby wygenerować losową nazwę wykorzystamy zasób `random_string`. Do stworzenia i zarządzalnia lokalnym plikiem przydatnym zasobem będzie `local_file`. Całość zostanie umieszczona z pliku `resources.tf`:
```
resource "random_string" "planowanie_wdrozenia" {
  length = "8"
}

resource "local_file" "planowanie_wdrozenia" {
  filename = random_string.planowanie_wdrozenia.result
  content = "Ćwiczenie 1.3 - Planowanie wdrożenia"
}
```
Jak widzisz każdy z zasobów ma pewne wspólne cechy:
* definiowany jest za pomocą bloku `resource`
* posiada swój typ (`random_string`, `local_file`)
* posiada swój identyfikator / nazwę (`planowanie_wdrozenia`)
* konfigurowany jest za pomocą predefiniowanych parametrów, które mogą być wymagane bądź opcjonalne

> Zwróć uwagę, że nasza konfiguracja definiuje dwa zasoby o innym typie lecz wspólnej nazwie. Tego typu praktyka jest dość popularna w sytuacji kiedy mamy niewiele zasobów, które są ze sobą mocno powiązane. W sytuacji kiedy Twoja konfiguracja jest bardziej rozbudowana bądź masz kilka zasobów tego samego typu, staraj się tworzyć nazwy, które jednoznacznie wskażą na zastosowanie danej instancji zasobu.

Dodatkowo w ramach naszego kodu Terraform wprowadziliśmy zależność jednego zasobu od drugiego - aby wytworzyć zasób `local_file` musimy najpier stworzyć zasób `random_string`. Tego typu relacja (zależność) jest widoczna w następującej linijce:
```
filename = random_string.planowanie_wdrozenia.result
```
O zależnościach oraz referencjach w kontekście różnych obiektów w Terraform będziemy mówić więcej w kolejnych ćwiczeniach.

### Planowanie zmian
Aby zaplanować zmiany (zobaczyć możliwy efekt ich działania) wykorzystamy komendę `plan`:
```
terraform plan
```
Wynikiem działania tej komendy będzie przedstawienie Tobie obrazu docelowego środowiska wdrożeniowego, które widzi Terraform:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.planowanie_wdrozenia will be created
  + resource "local_file" "planowanie_wdrozenia" {
      + content              = "Ćwiczenie 1.3 - Planowanie wdrożenia"
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

  # random_string.planowanie_wdrozenia will be created
  + resource "random_string" "planowanie_wdrozenia" {
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

Plan: 2 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

Ponieważ nigdy wcześniej nie aplikowaliśmy zmian z tej konfiguracji, Terraform posiada pusty plik stanu. Ponieważ plik stanu jest pusty, nasze zasoby z punktu widzenia Terraform powinny być utworzone. Wynik działania tej komendy jest więc właściwy - zaplanowane wdrożenie utworzy dwa zasoby.

Zwróć dodatkowo uwagę na wynik działania komendy `plan` w kontekście niektórych parametrów naszych zasobów, w szczególności `local_file`:
```
filename             = (known after apply)
```
Informacja `(known after apply)` wskazuje na brak możliwości określenia wartości przed aplikacją zmian. Wynika to bardzo często z tego, że niektóre wartości mogą być generowane dopiero w momencie kiedy zasób istnieje. Jeśli poszczególne zasoby zależą od wartości, które są generowane w locie, część konfiguracji może być niejawna do momentu zmaterializowania zmian. Nie należy się tym przejmować, chociaż może to miejscami utrudniać zrozumienie docelowego stanu naszej infrastruktury.

Aby zobaczyć jak będzie wyglądać nasza infrastruktura skieruj się do kolejnego ćwiczenia pt. `Aplikacja zmian`.