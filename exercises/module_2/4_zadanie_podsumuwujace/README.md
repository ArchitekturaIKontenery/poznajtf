# Zadanie podsumujące
## Opis
W ramach tego ćwiczenia spróbujesz samodzielnie wykorzystać zmienne w swojej konfiguracji napisanej w Terraform.

## Wykonanie ćwiczenia
Aby wykonać to ćwiczenie przygotuj samodzielnie konfigurację wg poniższych wytycznych:
* do tworzenia zasobów wykorzystaj zasób `local_file`
* zdefiniuj zmienną wejściową `files`, która może przyjąć dowolną liczbę następujących obiektów: `{ name = "<nazwa-pliku>", content = "<zawartosc-pliku>" }`
* wykorzystaj zmienną `files` zarówno w pętli `count` jak i `for_each`
* wykonaj operacje `plan` oraz `apply` aby utworzyć pliki

## Pomocne linki
https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file