# Ćwiczenie 5.2 - Praca z plikiem stanu
## Opis
W ramach tego ćwiczenia zobaczymy jak możemy pracować z plikiem stanu wprowadzając manualne zmiany.

## Wykonanie ćwiczenia
Aby zacząć ćwiczenie, utwórz plik `resources.tf` do której dodaj następującą definicję zasobu:
```
resource "local_file" "state" {
  content = jsonencode({
    "name" = "Terraform",
    "description" = "Przykładowy opis",
    "version" = "0.12.24"
  })
  filename = "local_file.json"
}
```
Wykonaj następnie operacje `init` oraz `apply` aby utworzyć plik lokalnie. Spróbujemy teraz wprowadzić małe modyfikacje do naszej konfiguracji.

## Renaming zasobu
Zauważ, że identyfikator naszego zasobu to `local_file.state`, który okazuje się dość niefortunną nazwą, która nie ma wiele wspólnego z zawartością. Jeśli zmienimy ten identyfikator przykładowo na `local_file.file`, okaże się, że Terraform będzie chciał ten plik utworzyć na nowo:
```
local_file.state: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

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

  # local_file.state will be destroyed
  # (because local_file.state is not in configuration)
  - resource "local_file" "state" {
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

Plan: 1 to add, 0 to change, 1 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────        

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Dla tego konkretnego zasobu tego typu operacja mogłaby być akceptowalna, jednak założymy, że z różnych przyczyn nie możemy jej wykonać. Jak w takim razie wprowadzić modyfikację aby nie utracić istniejącego zasobu? Okazuje się, że możemy manualnie zmienić plik stanu używając poniższej komendy:
```
terraform state mv local_file.state local_file.file
```
Jeśli teraz wykonamy operację `plan` zobaczymy, że Terraform tym razem nie widzi żadnej zmiany:
```
local_file.file: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
Jak widzisz, ta konkretna operacja może być wykorzystywana jako alternatywa dla bloku `moved`. Pamiętaj jednak, że nie zawsze możesz je stosować naprzemiennie:
* blok `moved` pozwala w łatwy sposób wymusić renaming identyfikatora poprzez umieszczenie go w repozytorium
* komenda `terraform state mv` wymusza na nas imperatywne podejście, co może być kłopotliwe przy większych zmianach

To, która opcja będzie opcją właściwą musisz ocenić samodzielnie rozważając wszystkie za oraz przeciw.

## Przenoszenie zasobu pomiędzy plikami stanu
Operacja `terraform state mv` pozwala na przekazanie dodatkowych parametrów `-state` oraz `-state-out`, które mogą być użyte do przeniesienia zasobu z jednego pliku stanu do drugiego. Niestety, ich wykorzystanie jest ograniczone do lokalnego backendu, dlatego też nie mają one większego zastosowania. Wykonujemy ją w następujący sposób:
```
terraform state mv -state terraform.tfstate -state-out terraform-new.tfstate local_file.file local_file.new_file
```
Po wykonaniu operacji, w pliku `terraform-new.tfstate` moglibyśmy zobaczyć, że powstał zasób o wskazanym przez nas identyfikatorze:
```
{
  "version": 4,
  "terraform_version": "1.3.6",
  "serial": 1,
  "lineage": "60ddc7ea-205d-94d5-59e6-913cef98a46d",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "local_file",
      "name": "new_file",
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
W niektórych przypadkach komenda ta może być przydatna to refactorowania kodu.

## Usuwanie zasobu z pliku stanu
Zakładając, że udało Ci się wykonać wszystkie operacje z poprzedniej części ćwiczenia spróbuj wykonać operację `plan`. Jeśli zobaczysz jakiekolwiek zmiany, wykonaj operację `apply`. Aby przejść dalej, upewnij się, że operacja `plan` niczego nie zwraca:
```
local_file.file: Refreshing state... [id=8863cdc8a06e38839cb103fd5c8448834b786802]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
Usuń następnie lokalny plik `local_file.json` ze swojego komputera. Ponowne wykonanie operacji `plan` wskaże, że Terraform wykrył, że plik nie istnieje i będzie chciał utworzyć go ponownie.
> Terraform zauważył, że lokalnego pliku brakuje ponieważ domyślnie odświeża stan naszych zasobów. Jeśli wykonasz operację `terraform plan -refresh=false` zauważysz, że Terraform nadal uważa, że lokalny plik istnieje.

W sytuacji kiedy plik został usunięty poza Terraform, pierwszą rzeczą, która przychodzi nam do głowy to usunięcie go z kodu. Niestety nie do końca jest to rozwiązanie - w niektórych sytuacjach może się okazać, że Terraform będzie chcieć usunąć zasób pomimo tego, że on już nie istnieje:
```
# local_file.file will be destroyed
  # (because local_file.file is not in configuration)
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
```
W tej sytuacji to co musimy zrobić to usunąć taki zasób ręcznie z pliku stanu. Wykorzystamy do tego operację `state rm`:
```
terraform state rm local_file.file
```
Po jej wykonaniu możemy bezpiecznie usunąć konfigurację zasobu z naszego kodu. Ostatecznie, Terraform powinien wrócić do bazowego stanu, gdzie nie ma jakichkolwiek zmian do wprowadzenia:
```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```