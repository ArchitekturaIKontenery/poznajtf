# Ćwiczenie 5.3 - Synchronizacja zmian
## Opis
W ramach tego ćwiczenia będziemy pracować z operacją `refresh`, która pozwala na określenie jak Terraform powinien odświeżać plik stanu w kontekście naszej konfiguracji.

## Wykonanie ćwiczenia
Aby zacząć ćwiczenie, utwórz plik `resources.tf` do której dodaj następującą definicję zasobu:
```
resource "local_file" "file" {
  content = jsonencode({
    "name" = "Terraform",
    "description" = "Przykładowy opis",
    "version" = "0.12.24"
  })
  filename = "local_file.json"
}
```
Wykonaj następnie operacje `init` oraz `apply` aby utworzyć plik lokalnie. Zobaczymy teraz jak operowanie parametrem `-refresh-only` wpłynie na zachowanie Terraform.

## Zrozumieć refresh
W momencie kiedy zaaplikowaliśmy zmiany z naszej konfiguracji Terraform, operacja `plan` zwróci nam brak zmian:
```
local_file.file: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
Zobaczmy jednak co się stanie, jeśli poza standardowym procesem usuniemy nasz zasób. Aby to wykonać, usuń plik `local_file.json` ze swojego katalogu. Ponownie wykonanie operacji `plan` zwróci nam już inny wynik:
```
local_file.file: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = jsonencode(
            {
              + description = "Przykładowy opis"
              + name        = "Terraform"
              + version     = "0.12.24"
            }
        )
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "local_file.json"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────        

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Jak widać, Terraform domyślnie odświeżył stan naszej infrastruktury i zauważył, że brakuje pliku, który jest widoczny w pliku stanu:
```
{
  "version": 4,
  "terraform_version": "1.3.6",
  "serial": 9,
  "lineage": "623f1e40-98af-53f4-778c-f6ad7a455468",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "local_file",
      "name": "file",
      "provider": "provider[\"registry.terraform.io/hashicorp/local\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "content": "{\"description\":\"Przykładowy opis\",\"name\":\"Terraform\",\"version\":\"0.12.24\"}",
            "content_base64": null,
            "content_base64sha256": "MWzO/87wqDdkstWogeW+96w+jW9ffz1Zn1pH98LJEts=",
            "content_base64sha512": "d+9VgLuN5CpeKRNeIwbMqSR4if20FVZWra1EdS/Gs6DmiA3YRi2lRTVWSGQL4/clPfXxlMmUz7CxOsRktgpz1A==",
            "content_md5": "1ad73edfa7273f243538b65ec919d0c9",
            "content_sha1": "8863cdc8a06e38839cb103fd5c8448834b786802",
            "content_sha256": "316cceffcef0a83764b2d5a881e5bef7ac3e8d6f5f7f3d599f5a47f7c2c912db",
            "content_sha512": "77ef5580bb8de42a5e29135e2306cca9247889fdb4155656adad44752fc6b3a0e6880dd8462da545355648640be3f7253df5f194c994cfb0b13ac464b60a73d4",
            "directory_permission": "0777",
            "file_permission": "0777",
            "filename": "local_file.json",
            "id": "8863cdc8a06e38839cb103fd5c8448834b786802",
            "sensitive_content": null,
            "source": null
          },
          "sensitive_attributes": []
        }
      ]
    }
  ],
  "check_results": null
}
```
Tego typu zachowanie jest na ogół przydatne z punktu widzenia utrzymania infrastruktury - jeśli ktoś (lub coś) przypadkowo usunęłoby nasz zasób, ponowne wdrożenie po prostu go odtworzy. Zobaczmy jednak co się stanie jesli nie pozwolimy Terraform na odświeżenie stanu. W tym celu wykonaj operację `plan -refresh=false`
```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
Okazuje się, że w takim scenariuszu Terraform nie widzi, że plik został usunięty. Jeśli teraz wykonalibyśmy operację `apply`, plik zostałby automatycznie utworzony:
```
local_file.file: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = jsonencode(
            {
              + description = "Przykładowy opis"
              + name        = "Terraform"
              + version     = "0.12.24"
            }
        )
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "local_file.json"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```
Byłoby to zapewne dość zaskakujące dla osoby, która wykonuje te komendy (badź wyzwoliła pipeline, który je wykonuje). Jak w takim razie podejść właściwie do tego tematu?

## Poprawne wykorzystanie refresh
Jeśli operacja `plan` nie odświeża stanu, tak samo powinna zostać wykonana operacja `apply`. Spróbujmy w takim razie wykonać polecenie `terraform apply -refresh=false`:
```
Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
Podobnie jak operacja `plan`, `apply` także nie wprowadzi żadnej zmiany. Wynika to z tego, że wyłączenie odświeżania stanu doprowadza do sytuacji, gdzie plik stanu staje się naszym źródłem prawdy. Ma to swojej zastosowania:
* pozwala na przyśpieszenie planowania i aplikowania zmian w większych konfiguracjach (nie musimy odpytywać zasobów na naszym środowisku o ich stan)
* gwarantuje, że zmiany przedstawione operacją `plan` są dokładnie tymi zmianami, które powinny się wykonać

Z drugiej strony pamiętaj o tym, że wyłączenie odświeżania ma sens w sytuacji, kiedy mamy pewność, że żaden zewnętrzny proces nie modyfikuje naszej infrastruktury. W innym przypadku mogłoby się okazać, że nadpisujemy wprowadzone zmiany bez żadnej kontroli oraz świadomości takiej operacji. Terraform ma jednak jeszcze jedną operację, która może okazać się przydatna w tym scenariuszu.

## Odświeżenie stanu
Jeśli chcemy unikać ciągłego odświeżania stanu, dobrym pomysłem może okazać się wykorzystanie parametru `-refresh-only`. Jeśli wykonamy teraz operację `plan`, zobaczymy, że plik został usunięty poza naszym procesem:
```
local_file.file: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply" which may have affected this plan:

  # local_file.file has been deleted
  - resource "local_file" "file" {
      - content              = jsonencode(
            {
              - description = "Przykładowy opis"
              - name        = "Terraform"
              - version     = "0.12.24"
            }
        ) -> null
      - content_base64sha256 = "MWzO/87wqDdkstWogeW+96w+jW9ffz1Zn1pH98LJEts=" -> null
      - content_base64sha512 = "d+9VgLuN5CpeKRNeIwbMqSR4if20FVZWra1EdS/Gs6DmiA3YRi2lRTVWSGQL4/clPfXxlMmUz7CxOsRktgpz1A==" -> null
      - content_md5          = "1ad73edfa7273f243538b65ec919d0c9" -> null
      - content_sha1         = "8863cdc8a06e38839cb103fd5c8448834b786802" -> null
      - content_sha256       = "316cceffcef0a83764b2d5a881e5bef7ac3e8d6f5f7f3d599f5a47f7c2c912db" -> null
      - content_sha512       = "77ef5580bb8de42a5e29135e2306cca9247889fdb4155656adad44752fc6b3a0e6880dd8462da545355648640be3f7253df5f194c994cfb0b13ac464b60a73d4" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = "local_file.json" -> null
      - id                   = "8863cdc8a06e38839cb103fd5c8448834b786802" -> null
    }


This is a refresh-only plan, so Terraform will not take any actions to undo these. If you were expecting these changes then you can apply this plan to record the updated values in the Terraform state without changing any       
remote objects.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Operacja ta mówi nam co się stanie jeśli odświeżymy stan, który obecnie obserwujemy. Jeśli wykonamy teraz operację `apply -refresh-only`, Terraform doprowadzi nasz plik stanu do właściwej postaci:
```
local_file.file: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply" which may have affected this plan:

  # local_file.file has been deleted
  - resource "local_file" "file" {
      - content              = jsonencode(
            {
              - description = "Przykładowy opis"
              - name        = "Terraform"
              - version     = "0.12.24"
            }
        ) -> null
      - content_base64sha256 = "MWzO/87wqDdkstWogeW+96w+jW9ffz1Zn1pH98LJEts=" -> null
      - content_base64sha512 = "d+9VgLuN5CpeKRNeIwbMqSR4if20FVZWra1EdS/Gs6DmiA3YRi2lRTVWSGQL4/clPfXxlMmUz7CxOsRktgpz1A==" -> null
      - content_md5          = "1ad73edfa7273f243538b65ec919d0c9" -> null
      - content_sha1         = "8863cdc8a06e38839cb103fd5c8448834b786802" -> null
      - content_sha256       = "316cceffcef0a83764b2d5a881e5bef7ac3e8d6f5f7f3d599f5a47f7c2c912db" -> null
      - content_sha512       = "77ef5580bb8de42a5e29135e2306cca9247889fdb4155656adad44752fc6b3a0e6880dd8462da545355648640be3f7253df5f194c994cfb0b13ac464b60a73d4" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = "local_file.json" -> null
      - id                   = "8863cdc8a06e38839cb103fd5c8448834b786802" -> null
    }


This is a refresh-only plan, so Terraform will not take any actions to undo these. If you were expecting these changes then you can apply this plan to record the updated values in the Terraform state without changing any       
remote objects.

Would you like to update the Terraform state to reflect these detected changes?
  Terraform will write these changes to the state without modifying any real infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
Rzuć teraz okiem na plik stanu `terraform.tfstate`, który masz lokalnie. Powinien on wyglądac mniej więcej tak:
```
{
  "version": 4,
  "terraform_version": "1.3.6",
  "serial": 10,
  "lineage": "623f1e40-98af-53f4-778c-f6ad7a455468",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```
Jak widać jest całkiem pusty jeśli chodzi o obserwowane zasoby. Jak więc rozumieć operacje, które wykonaliśmy? Wykorzystanie parametru `-refresh-only` pozwala nam w bezpieczny sposób odświeżyć plik stanu (dzięki możliwości wykonania operacji `plan` a potem `apply` w kontrolowany sposób). Parametr ten zmienia nieco sposób działania operacji `plan` oraz `apply` w taki sposób, że nie operujemy wtedy na naszych wdrożonych zasobach, a jedynie na definicjach zasobów w pliku stanu. Jeśli chcemy wykorzystywać parametr `-refresh=false`, powinniśmy to połączyć z cyklicznym `-refresh-only`, dzięki czemu możemy każdorazowo zdecydować jak powinna wyglądać wynikowa konfiguracja. 

Pamiętaj oczywiście, że wykorzystane przez nas parametry nie spowodowały usunięcia konfiguracji z plików Terraform. Ponowne wykonanie operacji `plan -refresh=false` pokaże, że lokalny plik powinien być utworzony:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = jsonencode(
            {
              + description = "Przykładowy opis"
              + name        = "Terraform"
              + version     = "0.12.24"
            }
        )
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "local_file.json"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Posługiwanie się tymi parametrami wymaga nieco wprawy, będzie jednak procentować w przypadku bardziej zaawansowanej infrastruktury, gdzie często musimy zmienić nieco sposób pracy z Terraform.