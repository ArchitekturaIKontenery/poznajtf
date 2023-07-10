# Zadanie podsumujące
## Opis
W ramach tego ćwiczenia spróbujesz samodzielnie wykorzystać zagadnienia z Modułu 5.

## Wykonanie ćwiczenia
Aby wykonać to ćwiczenie przygotuj samodzielnie konfigurację wg poniższych wytycznych:
* do tworzenia zasobów wykorzystaj zasób `local_file` oraz `local_sensitive_file`
* napisz moduł, który będzie tworzyć lokalny plik wg zadanych wytycznych (możliwość wskazania nazwy pliku, zawartości, uprawnień, czy plik wrażliwy)
* napisany moduł powinien także umożliwiać ustawienie zawartości z użyciem parametru `content_base64`. Użytkownik nie powinien jednak samodzielnie wykonywać konwersji zawartości
* moduł powinien być dostepny w ramach lokalnego systemu plików
* za pomocą modułu utwórz kilka plików, a następnie usuń jeden z nich
* zmień także identyfikator modułu dla jednego z utworzonych plików
* wykorzystaj operacje `state mv` oraz `state rm` aby zmodyfikować plik stanu (`terraform plan` pokazuje brak zmian)
* dodaj kilka nowych plików a następnie usuń kilka z nich
* wykorzystując operację `-refresh=false` oraz `-refresh-only` spróbuj ponownie rekoncyliować plik stanu

## Pomocne linki
https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
https://developer.hashicorp.com/terraform/language/modules/develop/refactoring