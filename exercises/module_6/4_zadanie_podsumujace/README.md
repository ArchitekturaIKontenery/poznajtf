# Zadanie podsumujące
## Opis
W ramach tego ćwiczenia spróbujesz samodzielnie wykorzystać zagadnienia z Modułu 6.

## Wykonanie ćwiczenia
Aby wykonać to ćwiczenie przygotuj samodzielnie konfigurację wg poniższych wytycznych:
* do tworzenia zasobów możesz wykorzystać dowolnego providera, który pozwala na wykorzystanie dodatkowych bloków wewnątrz definicji zasobów (Azure, GCP, AWS, Kubernetes)
* napisz lokalny moduł, który będzie wykorzystywał blok `dynamic` do dynamicznego określania konfiguracji zasobów definiowanych wewnątrz modułu
* wykorzystaj możliwości Terraform na dodanie walidacji - zarówno na poziomie zmiennych wejściowych, jak i warunków pre/post-condition
* wykorzystaj technikę `object attributes` aby określić przyjazny dla użytkownika interfejs swojego modułu

## Pomocne linki
https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
https://developer.hashicorp.com/terraform/tutorials/modules/module-object-attributes