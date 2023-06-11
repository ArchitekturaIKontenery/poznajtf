# Ćwiczenie 1.2 - Inicjalizacja konfiguracji
## Opis
W ramach tego ćwiczenia zainicjalizujemy naszą konfigurację w oparciu o zdefiniowanych providerów. Zwrócimy dodatkowo uwagę na wytwarzany plik `.terraform.lock.hcl`, który jest plikiem określającym zależności naszego kodu Terraform.

## Wykonanie ćwiczenia
Do tego ćwiczenia wykorzystamy pojedynczego providera `random`, który może być wykorzystany do generowania losowych wartości, przydatnych z punktu widzenia wykonywania testów czy też prototypowania konfiguracji infrastruktury.

### Definiowanie providera
Aby zdefiniować providera `random` musimy ponownie wykorzystać blok `terraform`:
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

W momencie kiedy nasz provider jest zdefiniowany, jesteśmy gotowi do zainicjalizowania konfiguracji.

### Inicjalizacja konfiguracji
Aby zainicjalizować konfigurację wykorzystamy polecenie `init`:
```
terraform init
```

Wynikiem działania tej komendy jest pobranie providera z jego źródła (w tym wypadku - publicznego rejestru). Zainicjalizowany provider dostępny będzie jako plik wykonywalny w ramach katalogu `.terraform`, który zostanie automatycznie utworzony w katalogu roboczym właściwym dla Twojego terminala:
```
.\.terraform\providers\registry.terraform.io\hashicorp\random\3.5.1\windows_amd64\terraform-provider-random_v3.5.1_x5.exe
```

Wersja providera będzie oczywiście zależna od wersji zdefiniowanej w ramach naszej konfiguracji Terraform. Ponieważ każdy provider może mieć oddzielną wersję zależną od naszego systemu operacyjnego, docelowa ścieżka, w ramach której jest pobrany, może zawierać nazwę tego systemu.
> Pamiętaj, że środowisko, gdzie inicjalizujesz konfigurację Terraform, może się różnić w zależności od miejsca uruchomienia komend Terraform. Ma to czasem znaczenie z punktu widzenia debuggowania błędów, gdzie może się zdarzyć, że konfiguracja działająca na Twoim komputerze nie zadziała na zdalnej maszynie inicjalizującej konfigurację na innym systemie operacyjnym.

Po poprawnej inicjalizacji Twój lokalny katalog roboczny powinien zawierać jeszcze jeden plik - `.terraform.lock.hcl`.

### Dependency lock file
Plik `.terraform.lock.hcl`, nazywany też _dependency lock file_, to plik tworzony automatycznie przez Terraform po zainicjalizowaniu konfiguracji. W momencie kiedy jest on utworzony, zawierać będzie informacje o wykorzystanych providerach oraz ich wersjach:
```
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/random" {
  version     = "3.5.1"
  constraints = "3.5.1"
  hashes = [
    "h1:3hjTP5tQBspPcFAJlfafnWrNrKnr7J4Cp0qB9jbqf30=",
    "zh:04e3fbd610cb52c1017d282531364b9c53ef72b6bc533acb2a90671957324a64",
    "zh:119197103301ebaf7efb91df8f0b6e0dd31e6ff943d231af35ee1831c599188d",
    "zh:4d2b219d09abf3b1bb4df93d399ed156cadd61f44ad3baf5cf2954df2fba0831",
    "zh:6130bdde527587bbe2dcaa7150363e96dbc5250ea20154176d82bc69df5d4ce3",
    "zh:6cc326cd4000f724d3086ee05587e7710f032f94fc9af35e96a386a1c6f2214f",
    "zh:78d5eefdd9e494defcb3c68d282b8f96630502cac21d1ea161f53cfe9bb483b3",
    "zh:b6d88e1d28cf2dfa24e9fdcc3efc77adcdc1c3c3b5c7ce503a423efbdd6de57b",
    "zh:ba74c592622ecbcef9dc2a4d81ed321c4e44cddf7da799faa324da9bf52a22b2",
    "zh:c7c5cde98fe4ef1143bd1b3ec5dc04baf0d4cc3ca2c5c7d40d17c0e9b2076865",
    "zh:dac4bad52c940cd0dfc27893507c1e92393846b024c5a9db159a93c534a3da03",
    "zh:de8febe2a2acd9ac454b844a4106ed295ae9520ef54dc8ed2faf29f12716b602",
    "zh:eab0d0495e7e711cca367f7d4df6e322e6c562fc52151ec931176115b83ed014",
  ]
}
```

Plik ten nie powinien być modyfikowany ręcznie - zarządza nim Terraform zależnie od swoich wewnętrznych reguł. Jednocześnie dość ważne jest to, aby ten plik dodawać do repozytorium z naszym kodem Terraform. W sytuacji kiedy wersje naszych providerów są zablokowane (o tym będziemy mówić później), sam _dependency lock file_ nie będzie tak istotny. Jesli jednak dopuszczamy różne wersje, w momencie kiedy jest on dostepny, każdy członek naszego zespołu (bądź pipeline CICD) będzie ładował identyczną wersję providera.