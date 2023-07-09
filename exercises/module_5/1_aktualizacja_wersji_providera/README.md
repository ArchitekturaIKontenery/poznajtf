# Ćwiczenie 5.1 - Aktualizacja wersji providera
## Opis
W ramach tego ćwiczenia zobaczymy w jaki sposób pracować z wersją providera - aktualizować, zmieniać constraint oraz go blokować.

## Wykonanie ćwiczenia
Aby zacząć ćwiczenie, pobierz kod dostępny w katalogu `exercises/modules_5/1_aktualizacja_wersji_providera/start`. Katalog ten zawiera kod Terraform oraz plik `.terraform.lock.hcl`, w ramach którego zdefiniowane są wersje providerów wykorzystanych w ramach stworzonej konfiguracji. Wykonaj operację `init`, która powinna zwrócić następujący wynik:
```
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/local from the dependency lock file
- Installing hashicorp/local v2.0.0...
- Installed hashicorp/local v2.0.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
Zwróć uwagę na poniższą linijkę:
```
- Reusing previous version of hashicorp/local from the dependency lock file
```
Oznacza ona, że dana wersja providera `local` zostaje pobrana na podstawie zawartości pliku `.terraform.lock.hcl`. Plik ten może mieć następującą formę:
```
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/local" {
  version     = "2.0.0"
  constraints = "2.0.0"
  hashes = [
    "h1:SlDBzk4mI74zgQY9JgNygoI2WRJ4ZIgCN3IkWRon2Ng=",
    "zh:34ce8b79493ace8333d094752b579ccc907fa9392a2c1d6933a6c95d0786d3f1",
    "zh:5c5a19c4f614a4ffb68bae0b0563f3860115cf7539b8adc21108324cfdc10092",
    "zh:67ddb1ca2cd3e1a8f948302597ceb967f19d2eeb2d125303493667388fe6330e",
    "zh:68e6b16f3a8e180fcba1a99754118deb2d82331b51f6cca39f04518339bfdfa6",
    "zh:8393a12eb11598b2799d51c9b0a922a3d9fadda5a626b94a1b4914086d53120e",
    "zh:90daea4b2010a86f2aca1e3a9590e0b3ddcab229c2bd3685fae76a832e9e836f",
    "zh:99308edc734a0ac9149b44f8e316ca879b2670a1cae387a8ae754c180b57cdb4",
    "zh:c76594db07a9d1a73372a073888b672df64adb455d483c2426cc220eda7e092e",
    "zh:dc09c1fb36c6a706bdac96cce338952888c8423978426a09f5df93031aa88b84",
    "zh:deda88134e9780319e8de91b3745520be48ead6ec38cb662694d09185c3dac70",
  ]
}
```
Zawiera on wszystkie informacje, które pozwalają Terraform na zablokowanie wykorzystanej wersji providera. Daje nam to pewność, że niezależnie od środowiska, gdzie wykonujemy komendy Terraform, provider będzie niezmienny.

## Zmiana wersji providera
Zdefiniowana obecnie wersja providera nie jest najnowsza - spróbujmy to zmienić wprowadzając następującą modyfikację:
```
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}
```
Wykonanie operacji `init` będzie jednak skutkować błędem:
```
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/local from the dependency lock file
╷
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider hashicorp/local: locked provider registry.terraform.io/hashicorp/local 2.0.0 does not match configured version constraint 2.4.0; must use terraform init -upgrade 
│ to allow selection of new versions
╵
```
Terraform nie pozwala nam zmienić lokalnie zainstalowanego providera na innego bez jawnego wskazania, że jest to oczekiwana przez nas operacja. Zanim zrobimy upgrade, zdefiniujmy wersję oczekiwanego providera tak, abyśmy nie musieli każdorazowo podbijać jej manualnie:
```
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = ">= 2.4.0, < 3"
    }
  }
}
```
Następnie wykonaj operację `init -upgrade`:
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/local versions matching "2.4.0"...
- Installing hashicorp/local v2.4.0...
- Installed hashicorp/local v2.4.0 (signed by HashiCorp)

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
Zwróć też uwagę na zmiany w `.terraform.lock.hcl`:
```
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/local" {
  version     = "2.4.0"
  constraints = "2.4.0"
  hashes = [
    "h1:7RnIbO3CFakblTJs7o0mUiY44dc9xGYsLhSNFSNS1Ds=",
    "zh:53604cd29cb92538668fe09565c739358dc53ca56f9f11312b9d7de81e48fab9",
    "zh:66a46e9c508716a1c98efbf793092f03d50049fa4a83cd6b2251e9a06aca2acf",
    "zh:70a6f6a852dd83768d0778ce9817d81d4b3f073fab8fa570bff92dcb0824f732",
    "zh:78d5eefdd9e494defcb3c68d282b8f96630502cac21d1ea161f53cfe9bb483b3",
    "zh:82a803f2f484c8b766e2e9c32343e9c89b91997b9f8d2697f9f3837f62926b35",
    "zh:9708a4e40d6cc4b8afd1352e5186e6e1502f6ae599867c120967aebe9d90ed04",
    "zh:973f65ce0d67c585f4ec250c1e634c9b22d9c4288b484ee2a871d7fa1e317406",
    "zh:c8fa0f98f9316e4cfef082aa9b785ba16e36ff754d6aba8b456dab9500e671c6",
    "zh:cfa5342a5f5188b20db246c73ac823918c189468e1382cb3c48a9c0c08fc5bf7",
    "zh:e0e2b477c7e899c63b06b38cd8684a893d834d6d0b5e9b033cedc06dd7ffe9e2",
    "zh:f62d7d05ea1ee566f732505200ab38d94315a4add27947a60afa29860822d3fc",
    "zh:fa7ce69dde358e172bd719014ad637634bbdabc49363104f4fca759b4b73f2ce",
  ]
}
```
Wraz ze zmianą version constraint, pojawiły się zmiany w tym pliku. Pamiętaj, aby ten plik zawsze był umieszczany w Twoim repozytorium. Pozwala to na zablokowanie wersji providera pomiędzy maszynami oraz środowiskami, dzięki czemu unikniesz nieprzewidzianych błędów oraz trudnych do namierzenia nieoczekiwanych zmian w konfiguracji.