# Ćwiczenie 3.3 - Wykorzystanie data source
## Opis
W ramach tego ćwiczenia zobaczymy jak wykorzystać blok data source do pobierania danych nt. zasobów.

## Wykonanie ćwiczenia
Aby wykonac to ćwiczenie skorzystaj z plików zawartych w katalogu `code`. Katalog `solution` zawiera gotowe rozwiązanie.

### Wykorzystanie data source
W ramach standardowej konfiguracji na ogół korzystamy z bloków `resource`, które pozwalają na zarządzanie infrastrukturą. Przykładem takiego bloku będzie blok definiujący plik lokalny:
```
resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World!"
}
```
Co jednak w sytuacji, kiedy zasób został już wcześniej wdrożony i chcielibyśmy umożliwić naszej konfiguracji w Terraform na odpytanie tego zasobu o jego właściwości? Załóżmy, że w ramach innego procesu utworzyliśmy plik `data.dat`, który miałby posłużyć nam do utworzenia nowego pliku z użyciem Terraform. Aby móc wykonac taką operację musielibyśmy wykorzystać blok `data source`:
```
data "local_file" "file" {
  filename = "data.dat"
}
```
Powyższy przykład zakłada, że plik znajduje się w tym samym katalogu co nasz kod Terraform. Spróbujmy teraz wykorzystać tę definicję do określenia zawartości pliku tworzonego za pomocą bloku `resource`:
```
resource "local_file" "file" {
  filename = "new_data.dat"
  content  = data.local_file.file.content
}
```
W tym momencie jeśli wykonamy operację `plan` powinniśmy zobaczyć, że zawartość tworzonego pliku jest pobrana z pliku, który został stworzony poza Terraform:
```
data.local_file.file: Reading...
data.local_file.file: Read complete after 0s [id=f29e0bd827569b4cae1844bd907e090c20b0dd92]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = "Wykonujesz ćwiczenie 3.3 z kursu PoznajTerraform!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "new_data.dat"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Zwróć uwagę na dwie nowe operacje, które pojawiły się w logu:
```
data.local_file.file: Reading...
data.local_file.file: Read complete after 0s [id=f29e0bd827569b4cae1844bd907e090c20b0dd92]
```
Lokalny plik faktycznie został odczytany wraz z zawartością - nie musiał być on dodany do pliku stanu bądź zaimportowany. Tego typu operacja (odczytanie kofiguracji zasobu za pomocą `data source`) jest dostępna dla większości zasobów - aby mieć pewność, sprawdź dokumentację swojego providera.

### Zależności dla data source
Każdy `data source`, podobnie jak bloki `resource`, mogą definiować zależności:
```
data "local_sensitive_file" "file" {
  depends_on = [ local_file.file ]
  filename = "sensitive_data.dat"
}

resource "local_sensitive_file" "file" {
  filename = "new_sensitive_data.dat"
  content  = data.local_sensitive_file.file.content
}
```
Powyższa konfiguracja wprowadza dwie zmiany:
* wykorzystany jest `data source`, który odczyta zawartość pliku `sensitive_data.dat`, jednocześnie jest on zależny od zasobu `local_file.file`
* utworzony będzie nowy plik `new_sensitive_data.dat` jeśli `data source` zdefiniowany jako `data.local_sensitive_file` zostanie wykonany

W momencie kiedy wykonamy operację `plan` zauważymy, że faktycznie odczytanie pliku `sensitive_data.dat` zostaje wstrzymane do momentu operacji `apply`:
```
data.local_file.file: Reading...
data.local_file.file: Read complete after 0s [id=f29e0bd827569b4cae1844bd907e090c20b0dd92]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.local_sensitive_file.file will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "local_sensitive_file" "file" {
      + content              = (sensitive value)
      + content_base64       = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + filename             = "sensitive_data.dat"
      + id                   = (known after apply)
    }

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = "Wykonujesz ćwiczenie 3.3 z kursu PoznajTerraform!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "new_data.dat"
      + id                   = (known after apply)
    }

  # local_sensitive_file.file will be created
  + resource "local_sensitive_file" "file" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0700"
      + file_permission      = "0700"
      + filename             = "new_sensitive_data.dat"
      + id                   = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

### Data source a pętle
Podobnie jak w blokach `resource`, bloki `data source` wspierają meta-argumenty `count` oraz `for_each`. Możemy je wykorzystać do odczytania więcej niżej jednego zasobu w ramach tej samej konfiguracji:
```
locals {
  files = ["file1.txt", "file2.txt", "file3.txt"]
}

data "local_file" "loop_file" {
  for_each = toset(local.files)
  filename = "files/${each.value}"
}

resource "local_file" "loop_file" {
  for_each = toset(local.files)
  filename = "new_${each.value}"
  content  = data.local_file.loop_file[each.key].content
}
```
Powyższa konfiguracja pokazuje w jaki sposób pliki zdefiniowane jako lista w ramach lokalnej zmiennej `files` jest wykorzystana do odczytania zawartości każdego z plików a następnie wykorzystania ich do utworzenia nowych:
```
data.local_file.loop_file["file1.txt"]: Reading...
data.local_file.loop_file["file2.txt"]: Reading...
data.local_file.file: Reading...
data.local_file.loop_file["file3.txt"]: Reading...
data.local_file.file: Read complete after 0s [id=f29e0bd827569b4cae1844bd907e090c20b0dd92]
data.local_file.loop_file["file3.txt"]: Read complete after 0s [id=f79ec4d7e53b30297adffbcc6dc21502af547ecd]
data.local_file.loop_file["file1.txt"]: Read complete after 0s [id=c84ad8b1227ffd52dc4bdbaae20c9a11e5f781c8]
data.local_file.loop_file["file2.txt"]: Read complete after 0s [id=7a9ca7e1e2ad074f3cd3416526e1677cd9e8ce71]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.local_sensitive_file.file will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "local_sensitive_file" "file" {
      + content              = (sensitive value)
      + content_base64       = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + filename             = "sensitive_data.dat"
      + id                   = (known after apply)
    }

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = "Wykonujesz ćwiczenie 3.3 z kursu PoznajTerraform!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "new_data.dat"
      + id                   = (known after apply)
    }

  # local_file.loop_file["file1.txt"] will be created
  + resource "local_file" "loop_file" {
      + content              = "Plik 1"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "new_file1.txt"
      + id                   = (known after apply)
    }

  # local_file.loop_file["file2.txt"] will be created
  + resource "local_file" "loop_file" {
      + content              = "Plik 2"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "new_file2.txt"
      + id                   = (known after apply)
    }

  # local_file.loop_file["file3.txt"] will be created
  + resource "local_file" "loop_file" {
      + content              = "Plik 3"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "new_file3.txt"
      + id                   = (known after apply)
    }

  # local_sensitive_file.file will be created
  + resource "local_sensitive_file" "file" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0700"
      + file_permission      = "0700"
      + filename             = "new_sensitive_data.dat"
      + id                   = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Zwróć też uwagę na to, że pliki są odczytywane w losowej kolejności:
```
data.local_file.loop_file["file1.txt"]: Reading...
data.local_file.loop_file["file2.txt"]: Reading...
data.local_file.file: Reading...
data.local_file.loop_file["file3.txt"]: Reading...
data.local_file.file: Read complete after 0s [id=f29e0bd827569b4cae1844bd907e090c20b0dd92]
data.local_file.loop_file["file3.txt"]: Read complete after 0s [id=f79ec4d7e53b30297adffbcc6dc21502af547ecd]
data.local_file.loop_file["file1.txt"]: Read complete after 0s [id=c84ad8b1227ffd52dc4bdbaae20c9a11e5f781c8]
data.local_file.loop_file["file2.txt"]: Read complete after 0s [id=7a9ca7e1e2ad074f3cd3416526e1677cd9e8ce71]
```
Wynika to z braku zdefiniowanych zależności pomiędzy nimi. Jeśli pliki miałyby być utworzone w sposób sekwencyjny, musielibyśmy wprowadzić jawne zależności za pomocą meta-argumentu `depends_on`. Spróbuj wykonać tego typu zmianę we własnym zakresie!