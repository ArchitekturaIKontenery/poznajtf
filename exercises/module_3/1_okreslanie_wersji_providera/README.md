# Ćwiczenie 3.1 - Określanie wersji providera
## Opis
W ramach tego ćwiczenia przećwiczymy różne sposoby określania wersji providera z użyciem __version constraints__. 

## Wykonanie ćwiczenia
Aby rozpocząć to ćwiczenie, zdefiniuj blok `terraform` w swoim kodzie w następujący sposób:
```
terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "=3.0.0"
        }

        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }

        google = {
            source  = "hashicorp/google"
            version = ">= 3.60"
        }
    }
}
```
Jak widzisz, konfiguracja naszych providerów wskazuje na 3 różne chmury (Azure, GCP, AWS) wraz z 3 różnymi sposobami oznaczenia wymaganej wersji. Zainicjalizuj konfigurację z użyciem operacji `init`. Powinna zwrócić ona wynik podobny do poniższego:
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 4.0"...
- Finding hashicorp/google versions matching ">= 3.60.0"...
- Finding hashicorp/azurerm versions matching "3.0.0"...
- Installing hashicorp/aws v4.67.0...
- Installed hashicorp/aws v4.67.0 (signed by HashiCorp)
- Installing hashicorp/google v4.69.1...
- Installed hashicorp/google v4.69.1 (signed by HashiCorp)
- Installing hashicorp/azurerm v3.0.0...
- Installed hashicorp/azurerm v3.0.0 (signed by HashiCorp)

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
Zwróć uwagę na to jakie wersje zostały wybrane w zależności od określonego __version constraint__:
* dla `=3.0.0` pobrana wersja to `v3.0.0`
* dla `~> 4.0` pobrana wersja to `v4.67.0`
* dla `>= 3.60` pobrana wersja to `v4.69.1`

Jeśli sprawdzisz teraz publiczny rejestr providerów w Terraform zauważysz, że dla tych konkretnych providerów dostępne są następujące wersje:
* dla `azurerm` - wersja `3.61.0`
* dla `aws` - wersja `5.4.0`
* dla `google` - wersja `4.69.1`

Widać więc, że __version constraint__ dość mocno wpłynęły na sposób doboru wersji providera. Dokonane wybory można opisać w następujący sposób:
* `=3.0.0` wybrało dokładnie wersję `3.0.0`
* `~> 4.0` wybrało ostatnią dostępną wersję `4.x` (gdzie w momencie pisania tego tekstu najnowsza wersja tego providera to `5.4.0`)
* `>= 3.60` wybrało ostatnią dostępną wersję większą niż `3.60`

Jak widzisz, pomimo zdefiniowania __version constraint__ mamy nadal dość duży przedział akceptowalnych wersji. Spróbujmy nieco ograniczyć wersje, które mogą być pobrane.

### Ograniczenia akceptowanych wersji
Zmodyfikuj swoją konfigurację w nastepujący sposób:
```
terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "=3.0.0"
        }

        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0.0"
        }

        google = {
            source  = "hashicorp/google"
            version = ">= 3.60, < 4.0"
        }
    }
}
```
Następnie wykonaj operację `init`, która jednak tym razem zakończy się błędem:
```
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/google from the dependency lock file
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v3.0.0
╷
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider hashicorp/google: locked provider registry.terraform.io/hashicorp/google 4.69.1 does not match configured version constraint >= 3.60.0, < 4.0.0; must use
│ terraform init -upgrade to allow selection of new versions
╵

╷
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider hashicorp/aws: locked provider registry.terraform.io/hashicorp/aws 4.67.0 does not match configured version constraint ~> 4.0.0; must use terraform init -upgrade 
│ to allow selection of new versions
```
Sytuacja ta zostanie omówiona nieco bardziej szczegółowo w dalszej części kursu, jednak nie pozostawiajmy jej bez nawet krótkiego wytłumaczenia. Ponieważ zainicjalizowaliśmy już wcześniej naszą konfigurację, Terraform nie pozwala na aktualizację wersji providera bez naszej jawnej deklaracji. Służy to uniknięciu przypadkowej aktualizacji, która mogłaby wprowadzić niekompatybilne zmiany do naszej konfiguracji (bądź spowodować ukryte efekty uboczne, które zmodyfikują stan naszej infrastruktury). Aby ponownie zainicjalizować naszą konfigurację mamy dwie możliwości:
* usunięcie katalogu `.terraform` oraz pliku `.terraform.lock.hcl`
* wykonanie operacji `terraform init -upgrade`

Aby wykonać tę operację zgodnie ze sztuką wybieramy opcję numer 2:
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 4.0.0"...
- Finding hashicorp/google versions matching ">= 3.60.0, < 4.0.0"...
- Finding hashicorp/azurerm versions matching "3.0.0"...
- Installing hashicorp/aws v4.0.0...
- Installed hashicorp/aws v4.0.0 (signed by HashiCorp)
- Installing hashicorp/google v3.90.1...
- Installed hashicorp/google v3.90.1 (signed by HashiCorp)
- Using previously-installed hashicorp/azurerm v3.0.0

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
Podsumujmy naszą konfigurację:
* wersja `azurerm` pozostała bez zmian
* dla `aws` określenie wersji jako `~> 4.0.0` spowodowało pobranie wersji `v4.0.0`
* dla `google` wersja określona jako `>= 3.60, < 4.0` pobiera wersję `v3.90.1`

Sytuacja ta wygląda znacznie lepiej niż poprzednio - mamy większą kontrolę nad pobraną wersją a w przypadku `google` nie dopuściliśmy do sytuacji, w której zmieniła się wersja __major__ w kontekście wybranej wersji providera (oczywiście zakładając konwencję SemVer). Dla `aws` mimo wszystko operator `~>` może być nieco bardziej enigmatyczny. Dlaczego `~> 4.0` pobierał `v4.67.0` a dla `~> 4.0.0` jest to dokładnie wersja `v4.0.0`?

W kontekście Terraform `~>` pozwala na ograniczenie wersji do ostatniej wersji w ramach jej określonego składnika. Posłużmy się tutaj nieco bardziej obrazowym przykładem - założmy, że nasza wersja składa się z 3 składników:
```
[a].[b].[c]
```
Zdefiniujmy się 3 __version constraint__:
* `~> [a]`
* `~> [a].[b]`
* `~> [a].[b].[c]`

Na sam koniec przygotujmy listę wersji:
* `1.0.0`
* `1.1.0`
* `1.2.0`
* `2.0.0`
* `2.1.0`
* `2.1.1`
* `2.1.2`
* `2.2.0`

Zdefiniowane przez nas __version constraint__ zadziałają w następujący sposób:
* `~> [a]` zwróci maksymalną dostępną wersję w ramach `[a]`, np. `~ 1` daje `1.2.0` 
* `~> [a].[b]` zwróci maksymalną dostępną wersję w ramach `[a].[b]`, np. `~ 1.1` daje `1.2.0` i jednocześnie pozwala na określenie minimalnej wersji na `1.1` 
* `~> [a].[b].[c]` zwróci maksymalną dostępną wersję w ramach `[a].[b].[c]`, np. `~ 2.1.0` daje `2.1.2` czyli ustawia na sztywno elementy `[a].[b]` i zwraca maksymalną wersję `[c]`

Spróbuj poćwiczyć z różnymi wersjami aby zobaczyć jak Terraform określi wersję w Twoim wypadku. Możesz wykorzystać do tego dowolnego providera (nie musi być to provider do chmury).