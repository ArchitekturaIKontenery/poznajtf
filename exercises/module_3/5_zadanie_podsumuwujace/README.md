# Zadanie podsumujące
## Opis
W ramach tego ćwiczenia spróbujesz samodzielnie wykorzystać zagadnienia z Modułu 3.

## Wykonanie ćwiczenia
Aby wykonać to ćwiczenie przygotuj samodzielnie konfigurację wg poniższych wytycznych:
* do tworzenia zasobów wykorzystaj zasób `local_file` oraz `local_sensitive_file`
* zdefiniuj zmienną wejściową `files`, która może przyjąć dowolną liczbę następujących obiektów: `{ name = "<nazwa-pliku>", content = "<zawartosc-pliku>", file_permissions = "<uprawnienia>" }`
* wykorzystaj zmienną `files` w pętli `count` aby utworzyć pliki `local_file` poza katalogiem z kodem Terraform
* w oddzielnym katalogu przygotuj nową konfigurę, która za pomocą odpowiednich `data source` pobierze zawartość utworzonym plików a następnie zapisze je w nowym katalogu jako `local_sensitive_file`
* na sam koniec ogranicz zmiany zasobów `local_sensitive_file` poprzez uniemożliwienie ich usunięcia
* pamiętaj aby wykorzystywać operacje `plan` oraz `apply` aby kontrolować zmiany

## Pomocne linki
https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file