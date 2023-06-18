# Ćwiczenie 2.3 - Pętle
## Opis
W ramach tego ćwiczenia zobaczymy w jaki sposób wykorzystać dostępne pętle w Terraform.

## Wykonanie ćwiczenia
Pętlę w Terraform możemy podzielić na 3 typy:
* `for`
* `foreach`
* `count`

Każdy z typów można wykorzystać w nieco innym scenariuszu dlatego też nie należy się ograniczać tylko do jednego z nich. Postarajmy się znaleźć przypadki użycia dla wszystkich typów.

### Przygotowanie początkowej konfiguracji
Zacznijmy od zdefiniowania pojedynczego zasobu `local_file`, który posłuży nam za punkt startowy:
```
resource "local_file" "petle" {
  filename        = "plik1.txt"
  content         = "Ćwiczenie 2.3 - Pętle!"
}
```
Jeśli teraz chcielibyśmy stworzyć trzy identyczne pliki różniące się zawartością, możemy z jednej strony po prostu skopiować konfigurację:
```
resource "local_file" "file1" {
  filename        = "plik1.txt"
  content         = "Ćwiczenie 2.3 - Pętle! Plik 1"
}

resource "local_file" "file2" {
  filename        = "plik2.txt"
  content         = "Ćwiczenie 2.3 - Pętle! Plik 2"
}

resource "local_file" "file3" {
  filename        = "plik3.txt"
  content         = "Ćwiczenie 2.3 - Pętle! Plik 3"
}
```
Tego typu podejście jest jednak błędogenne i utrudnia utrzymanie kodu. Spróbujmy zrobić mały refaktor kodu aby trochę usprawnić naszą pracę.

### Podejście 1 - pętla `count`
`count` jest meta-argumentem, który dostępny jest dla każdego typu zasobu. Pozwala nam w bardzo łatwy sposób określić liczbę kopiowanych elementów i powielić konfigurację:
```
resource "local_file" "file" {
  count = 3

  filename = "plik${count.index}.txt"
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${count.index}"
}
```
Jeśli wykonamy teraz polecenie `plan` zobaczymy, że Terraform utworzyłby zamiast jednego to trzy pliki:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.file[0] will be created
  + resource "local_file" "file" {
      + content              = "Ćwiczenie 2.3 - Pętle! Plik 0"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "plik0.txt"
      + id                   = (known after apply)
    }

  # local_file.file[1] will be created
  + resource "local_file" "file" {
      + content              = "Ćwiczenie 2.3 - Pętle! Plik 1"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "plik1.txt"
      + id                   = (known after apply)
    }

  # local_file.file[2] will be created
  + resource "local_file" "file" {
      + content              = "Ćwiczenie 2.3 - Pętle! Plik 2"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "plik2.txt"
      + id                   = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────        

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

Jednym meta-argumentem jesteśmy w stanie oszczędzić sobie sporo pisania nadmiarowej konfiguracji. Widać jednak jeden problem - zmieniły się nazwy plików. Wcześniej mieliśmy:
* `plik1.txt`
* `plik2.txt`
* `plik3.txt`

Po wykorzystaniu pętli `count` mamy:
* `plik0.txt`
* `plik1.txt`
* `plik2.txt`

Aby zaradzić tej sytuacji mamy dwa wyjścia. Możemy zmodyfikować indeks w ramach konfiguracji poprzez prostą operację dodawania:
```
resource "local_file" "file" {
  count = 3

  filename = "plik${count.index+1}.txt"
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${count.index+1}"
}
```
Możemy też zdefiniować zmienną lokalną, w ramach której wskażemy nazwy plików:
```
locals {
  files = ["plik1.txt", "plik2.txt", "plik3.txt"]
}

resource "local_file" "file" {
  count = length(local.files)

  filename = local.files[count.index]
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${local.files[count.index]}"
}
```

Oba rozwiązania będą miały swoje wady oraz zalety. Oba scenariusze pozostawiam Ci do oceny.

### Podejście 2 - pętla `for_each`
Podobnie jak `count`, `for_each` jest meta-argumentem, którego można wykorzystać na poziomie każdego zasobu. W przeciwieństwie jednak do `count` wymaga on na wejściu kolekcji, która posłuży nam do wykonania pętli. Na potrzeby naszej konfiguracji możemy zdefiniować zmienną lokalną, która pozwoli nam na wykonanie pętli:
```
locals {
  additional_files = ["plik4.txt", "plik5.txt"]
}

resource "local_file" "additional_file" {
  for_each = toset(local.additional_files)

  filename = each.key
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${each.value}"
}
```
Zwróć uwagę na następującą rzecz - zmienna `local.additional_files` jest zdefiniowana jako kolekcja (lista), natomiast pętla `for_each` na wejściu nie przyjmuje tego typu, gdyż wymagane jest, aby elementy kolekcji zawierały zarówno klucz jak i wartość. Z tego powodu wykorzystujemy funkcję `toset()`, która powoduje, że Terraform wykona następującą transformację:
```
["plik4.txt", "plik5.txt"] -> {
    "file4.txt" = "file5.txt",
    "file5.txt" = "file4.txt"
}
```
Ten sam efekt osiągnęlibyśmy za pomocą następującego kodu:
```
locals {
  additional_files = {
    "file4.txt" = "file5.txt",
    "file5.txt" = "file4.txt"
  }
}

resource "local_file" "additional_file" {
  for_each = local.additional_files

  filename = each.key
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${each.value}"
}
```
Oczywiście wartość (`value`) nie musi być typem prostym. Jeśli chcesz, może to być typ złożony (obiekt, mapa, lista), do którego odniesiesz się w standardowy sposób `pole.wartość`. W kolejnych ćwiczeniach będziemy budować znacznie bardziej zaawansowane konfiguracje. Aby jednak utrwalić zdobytą wiedzę, spróbuj zaimplementować kod, w którym lokalna zmienna `additional_files` będzie zawierać jako wartości nie łańcuchy znaków, tylko obiekt o następującej strukturze:
```
additional_files = {
  "<key>" = {
    filename(string),
    content(string),
    file_permission(string)
  }
}
```
Następnie wykorzystaj te pola do uzupełnienia konfiguracji zasobu `local_file.additional_file`.

### Pętla `for`
Wyrażenie `for`, w przeciwieństwie do `count` oraz `for_each` nie jest typową pętlą w rozumieniu pętli tworzonych w różnych językach programowania. Jest to raczej operator, który pozwala nam na transformowanie jednego typu w drugi z użyciem odpowiednich funkcji dostępnych dla kodu Terraform. Możemy to dość łatwo zobrazować następującym przykładem:
```
locals {
  transformed_names = [for name in local.files : upper(name)]
}

resource "local_file" "transformed_file" {
  count = length(local.files)

  filename = local.transformed_names[count.index]
  content  = "Ćwiczenie 2.3 - Pętle! Plik ${local.transformed_names[count.index]}"
}
```
W momencie kiedy wykonasz operację `plan`, zobaczysz, że wygenerowane nazwy plików zostały faktycznie przekształcone zgodnie z wynikiem działania funkcji `upper()`:
```
# local_file.transformed_file[0] will be created
+ resource "local_file" "transformed_file" {
    + content              = "Ćwiczenie 2.3 - Pętle! Plik PLIK1.TXT"
    + content_base64sha256 = (known after apply)
    + content_base64sha512 = (known after apply)
    + content_md5          = (known after apply)
    + content_sha1         = (known after apply)
    + content_sha256       = (known after apply)
    + content_sha512       = (known after apply)
    + directory_permission = "0777"
    + file_permission      = "0777"
    + filename             = "PLIK1.TXT"
    + id                   = (known after apply)
  }

# local_file.transformed_file[1] will be created
+ resource "local_file" "transformed_file" {
    + content              = "Ćwiczenie 2.3 - Pętle! Plik PLIK2.TXT"
    + content_base64sha256 = (known after apply)
    + content_base64sha512 = (known after apply)
    + content_md5          = (known after apply)
    + content_sha1         = (known after apply)
    + content_sha256       = (known after apply)
    + content_sha512       = (known after apply)
    + directory_permission = "0777"
    + file_permission      = "0777"
    + filename             = "PLIK2.TXT"
    + id                   = (known after apply)
  }

# local_file.transformed_file[2] will be created
+ resource "local_file" "transformed_file" {
    + content              = "Ćwiczenie 2.3 - Pętle! Plik PLIK3.TXT"
    + content_base64sha256 = (known after apply)
    + content_base64sha512 = (known after apply)
    + content_md5          = (known after apply)
    + content_sha1         = (known after apply)
    + content_sha256       = (known after apply)
    + content_sha512       = (known after apply)
    + directory_permission = "0777"
    + file_permission      = "0777"
    + filename             = "PLIK3.TXT"
    + id                   = (known after apply)
  }
```
Jest to oczywiście jedno z zastosowań - wyrażenie `for` pozwala także na filtrowanie oraz grupowanie elementów. Wykorzystamy te funkcje w bardziej zaawansowanych konfiguracjach tworzonych w następnych ćwiczeniach.