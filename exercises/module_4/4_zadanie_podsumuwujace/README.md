# Zadanie podsumujące
## Opis
W ramach tego ćwiczenia spróbujesz samodzielnie wykorzystać zagadnienia z Modułu 4.

## Wykonanie ćwiczenia
Aby wykonać to ćwiczenie przygotuj samodzielnie konfigurację wg poniższych wytycznych:
* do tworzenia zasobów wykorzystaj zasób `local_file` oraz `local_sensitive_file`
* napisz moduł, który będzie tworzyć lokalny plik wg zadanych wytycznych (możliwość wskazania nazwy pliku, zawartości, uprawnień, czy plik wrażliwy)
* napisany moduł powinien także umożliwiać ustawienie zawartości z użyciem parametru `content_base64`. Użytkownik nie powinien jednak samodzielnie wykonywać konwersji zawartości
* moduł opublikuj na swoim GitHub i spróbuj wykorzystać w swojej konfiguracji
* na koniec spróbuj zmodyfikować identyfikatory zasobów w swoim module w taki sposób, aby użytkownicy mogli nadal bezpiecznie z niego korzystać (`moved` + opublikowanie nowej wersji modułu za pomocą tagów w repozytorium)

## Pomocne linki
https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
https://developer.hashicorp.com/terraform/language/modules/develop/refactoring