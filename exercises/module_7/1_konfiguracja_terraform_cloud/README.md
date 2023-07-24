# Ćwiczenie 7.1 - Konfiguracja Terraform Cloud
## Opis
W ramach tego ćwiczenia nauczysz się w jaki sposób zacząć pracę z Terraform Cloud.

## Wykonanie ćwiczenia
Naukę Terraform Cloud zaczynamy od utworzenia konta. Utwórz darmowe konto (https://app.terraform.io/public/signup/account) a następnie zaloguj się do niego z użyciem skonfigurowanych przez siebie poświadczeń. 

## Tworzenie organizacji
Aby móc pracować z Terraform Cloud musimy utworzyć organizację (https://app.terraform.io/app/organizations/new). Organizacja to nadrzędny element w hierarchii obiektów Terraform Cloud, który pozwala na na logiczne grupowanie projektów. Po utworzeniu organizacji (potrzebujesz tylko nazwy oraz swojego maila), zobaczysz ekran tworzenia workspace. 

## Tworzenie workspace
W Terraform Cloud możemy utworzyć jeden z trzech typów workspace:
* version control
* CLI-driven
* API-driven 

Każdy z tych typów ma swoje wady oraz zalety, każdy może być także zastosowany w większości projektów. W typowej projektowej pracy najlepszą opcją na ogół jest workspace oparty o system kontroli wersji (version control), niemniej jednak z dwóch pozostałych także można korzystać bez większych trudności. W ramach tego ćwiczenia spróbujemy skonfigurować workspace oparty właśnie o system kontroli wersji. W tym celu podczas tworzenia workspace wybierz opcję **Version control workflow** a następnie jednego z dostępnych providerów. Wybór providera ma drugorzędne znaczenie - ćwiczenie możesz wykorzystać łącząc się z GitHub, Azure DevOps, GitLab czy Bitbucket. W moim wypadku wykorzystam GitHub. W momencie kiedy workspace jest utworzony, możemy spróbować wykorzystać naszą integrację do wykonania operacji w Terraform.

## Dodanie zasobów
W ramach swojego repozytorium dodaj pojedynczy plik `resources.tf`, w którym umieść następującą definicję zasobu:
```
resource "local_file" "file" {
  content  = "Hello, World!"
  filename = "hello.txt"
}
```
Wykonaj następnie operację `git push` na swoim repozytorium. Wszelkie zmiany, które zostaną dodane do repozytorium, zostaną automatycznie wykryte przez Terraform Cloud. Wszelkie uruchomienia Twojego workspace można śledzić w zakładce **Runs** (https://app.terraform.io/app/<organization>/workspaces/<workspace>/runs).

Domyślnie Terraform Cloud wykonuje automatycznie tylko operację `plan` - operacja `apply` wymaga bezpośredniej interakcji z Twoim workspace. Jeśli takie zachowanie nie jest zgodne z Twoim założeniami, można je zmienić na poziomie ustawień Twojego workspace (https://app.terraform.io/app/<organization>/workspaces/<workspace>/settings/general).
> Zwróć uwagę na to, że w przypadku darmowego konta możesz mieć jednocześnie tylko jedno aktywne uruchomienie Twojego workspace. Oznacza to, że każdorazowo musisz albo wykonać operację `apply`, albo zignorować proponowane zmiany klikając na **Discard**.

## Zmienne
W sytuacji kiedy Twoja konfiguracja definiuje zmienne wejściowe, które miałyby być przekazane w ramach uruchomienia workspace, Terraform Cloud pozwala na ich zdefiniowanie z określoną wartością. Służy do tego zakładka **Variables** (https://app.terraform.io/app/<organization>/workspaces/<workspace>/variables). W pierwszej kolejności dodaj do swojego repozytorium plik `variables.tf` wraz z definicją zmiennej:
```
variable "filename" {
  type = string
  default = "hello.txt"
}
```
Następnie w zakładce **Variables** zdefiniuj zmienną dla workspace (Workspace variables) o nazwie `filename` z dowolną wartością. W momencie kiedy Twój workspace zostanie wyzwolony, nazwa utworzonego pliku powinna zgadzać się z wartością zmiennej `filename`, która została przez Ciebie zdefiniowana. 