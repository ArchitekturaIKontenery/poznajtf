# Ćwiczenie 4.2 - Korzystanie z publicznego modułu
## Opis
W ramach tego ćwiczenia skorzystamy z publicznie dostępnego modułu aby zobaczyć jak pracować z nimi w zalezności od wersji.

## Wykonanie ćwiczenia
Jeśli wejdziesz do repozytorium naszego kursu, zobaczysz, że mamy tam opublikowany jeden moduł `local_file` (https://github.com/ArchitekturaIKontenery/poznajtf/tree/main/modules/local_file). Moduł ten jest bardzo podobny do lokalnego modułu, którego utworzyliśmy w poprzednim ćwiczeniu. Zobaczymy teraz w jaki sposób z niego skorzystać we własnej konfiguracji. W tym celu utwórz plik `resources.tf` a następnie dodaj do niego następujący kod:
```
module "local_file" {
    source = "github.com/ArchitekturaIKontenery/poznajtf/modules/local_file"
}
```
Na koniec zainicjalizuj swoją konfigurację za pomocą operacji `init:
```
Initializing modules...
Downloading git::https://github.com/ArchitekturaIKontenery/poznajtf.git for local_file...
- local_file in .terraform\modules\local_file\modules\local_file

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/local...
- Installing hashicorp/local v2.4.0...
- Installed hashicorp/local v2.4.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
Jak widzisz, udało nam się zainicjalizować konfigurację wykorzystując moduł dostępny publicznie (w tym wypadku - repozytorium git (GitHub)). Spróbujmy utworzyć pliki z użyciem tego modułu.

## Wykorzystanie publicznego modułu
Dostępny publicznie moduł ma podobną konfigurację do naszego lokalnego modułu z poprzedniego ćwiczenia. Zmień wywołanie modułu w swoim kodzie na następujące:
```
module "local_file" {
    source = "github.com/ArchitekturaIKontenery/poznajtf/modules/local_file"

    is_sensitive = false
    content      = "Created from remote module!"
    filename     = "remote_file.txt"
}
```
Wykonaj teraz operację `plan`:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.local_file.local_file.local_file[0] will be created
  + resource "local_file" "local_file" {
      + content              = "Created from remote module!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "remote_file.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Jak widać, utworzony plik miałby zmienioną nazwę oraz zawartość zgodnie z tym, co przekazaliśmy. Wykonaj operację `apply` aby potwierdzić zmiany. Spróbuj też wykorzystać parametr `is_sensitive` aby zobaczyć jak zachowa się moduł.

## Wybieranie wersji modułu
Opublikowany moduł ma dwie wersje:
* `1.0.0`
* `1.1.0`

Spróbuj zmienić teraz referencję do modułu w następujący sposób:
```
source = "github.com/ArchitekturaIKontenery/poznajtf/modules/local_file" -> source = "git::https://github.com/ArchitekturaIKontenery/poznajtf.git//modules/local_file?ref=1.0.0"
```
Zmieniamy sposób w jaki wskazujemy na moduł poprzez wykorzystanie generycznego linka do repozytorium Git. Dodatkowo wykorzystujemy parametr `ref=1.0.0` wskazując na wersję `1.0.0` modułu. Ponieważ wersja się zmieniła, wykonaj ponownie operację `init` a następnie wykonaj operację `plan`:
```
╷
│ Error: Unsupported argument
│
│   on resources.tf line 5, in module "local_file":
│    5:     content      = "Created from remote module!"
│
│ An argument named "content" is not expected here.
╵
╷
│ Error: Unsupported argument
│
│   on resources.tf line 6, in module "local_file":
│    6:     filename     = "remote_file.txt"
│
│ An argument named "filename" is not expected here.
```
Okazuje się, że wersja `1.0.0` nie wspiera argumentów `content` oraz `filename`! Aby rozwiązać ten problem musielibyśmy albo zrezygnować z ich przekazania (polegając na wewnętrznej logice modułu), albo podbić wersję do `1.1.0`:
```
module "local_file" {
    source = "git::https://github.com/ArchitekturaIKontenery/poznajtf.git//modules/local_file?ref=1.1.0"

    is_sensitive = false
    content      = "Created from remote module!"
    filename     = "remote_file.txt"
}
```
Terraform, w momencie kiedy nie wskażemy gałęzi albo taga, wybiera zawsze najnowszą dostępną wersję modułu. Pamiętaj, że nie oznacza to, że wybrany zostaje najnowszy tag - jeśli nie wskażemy na konkretny punkt w czasie, Terraform będzie pobierał wersję modułu dostępną w ramach najnowszego commita!