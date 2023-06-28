# Ćwiczenie 3.4 - Wykorzystanie lifecycle
## Opis
W ramach tego ćwiczenia wykorzystamy blok lifecycle aby sterować naszym zasobem w ramach jego cyklu życia.

## Wykonanie ćwiczenia
Aby wykonac to ćwiczenie utwórz plik `resources.tf`, do którego dodaj pojedynczy zasób wg poniższego schematu:
```
resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World!"
}
```
W następnych krokach zaczniemy nim sterować za pomocą `lifecycle`.

### Ignorowanie zmian
Jednym z najpopularniejsych sposobów wykorzystania `lifecycle` jest funkcjonalność `ignore_changes`. Definiowana jest ona w następujący sposób:
```
resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World!"

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}
```
Jeśli w tym momencie wykonasz operację `apply`, zasób zostanie utworzony bez niczego niespodziewanego:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.file will be created
  + resource "local_file" "file" {
      + content              = "Hello, World!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "file.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.file: Creating...
local_file.file: Creation complete after 0s [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
Spróbujmy jednak w następnym kroku zmodyfikować parametr `content` na inny:
```
resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World! - ${timestamp()}"

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}
```
Wykonaj teraz operację `plan` aby zobaczyć jak zasób będzie wyglądać po wprowadzeniu tej zmiany:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
O dziwo, Terraform twierdzi, że nie ma żadnej zmiany do wprowadzenia! Wygląda na to, że blok `ignore_changes` spowodował, że Terraform zaczyna ignorować zmiany wartości pól, które zostały do niego przekazane. Dla potwierdzenia dodajmy nowy parametr:
```
resource "local_file" "file" {
  filename = "file.txt"
  content  = "Hello, World! - ${timestamp()}"
  file_permission = "0770"

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}
```
Ponownie wykonujemy operację `plan`:
```
local_file.file: Refreshing state... [id=0a0a9f2a6772942557ab5355d76af442f8f65e01]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.file must be replaced
-/+ resource "local_file" "file" {
      ~ content              = "Hello, World!" -> (known after apply)
      ~ content_base64sha256 = "3/1gIbsr1bCvZ2KQgJ7DpTGR3YHH9wpLKGiKNiGCmG8=" -> (known after apply)
      ~ content_base64sha512 = "N015SpXNz9izWZMYX++bo2jxYNja9DLQi6nx7R5avmzGkpHg+i/gAGpSVw7xjBne9OYXwzzlLvCm5fvjGMsDhw==" -> (known after apply)
      ~ content_md5          = "65a8e27d8879283831b664bd8b7f0ad4" -> (known after apply)
      ~ content_sha1         = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> (known after apply)
      ~ content_sha256       = "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f" -> (known after apply)
      ~ content_sha512       = "374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387" -> (known after apply)
      ~ file_permission      = "0777" -> "0770" # forces replacement
      ~ id                   = "0a0a9f2a6772942557ab5355d76af442f8f65e01" -> (known after apply)
        # (2 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Zauważ jednak, że w momencie kiedy wykonamy operację `apply`, zawartość pliku zmieni się:
```
Hellow, World! -> Hello, World! - 2023-06-28T15:49:19Z
```
Blok `ignore_changes` nie powoduje, że dany parametr nigdy już nie zmieni wartości. Pozwala jednak na sterowanie zachowaniem Terraform w taki sposób, aby zmiany okreslonych parametrów nie wyzwalały zmian na poziomie zasobu. Spróbuj dodać kilka dodatkowych parametrów do zasobu `local_file.file` i skonfiguruj blok `ignore_changes` aby nie wyzwalały one aplikowania zmian w Terraform.

## Tworzenie przed usunięciem
Druga właściwość bloku `lifecycle` którą omówimy to `create_before_destroy`. Jest to właściwość, która powoduje odwrócenie kolejności operacji w Terraform. W standardowym scenariuszu Terraform najpierw usuwa zasób a dopiero potem go tworzy na nowo. Jeśli wykorzystamy `create_before_destroy`, Terraform najpierw zasób utworzy, a dopiero potem usunie stary. Definiujemy go w następujący sposób:
```
resource "local_file" "file2" {
  filename = "file2.txt"
  content  = "Hello, World! - ${timestamp()}"
  file_permission = "0770"

  lifecycle {
    create_before_destroy = true
  }
}
```
Zaaplikuj zmiany z użyciem operacji `apply`. Następnie spróbuj zmienić konfigurację zasobu w następujący sposób:
```
resource "local_file" "file2" {
  filename = "file2.txt"
  content  = "Hello, World! - ${timestamp()}"
  file_permission = "0777"

  lifecycle {
    create_before_destroy = true
  }
}
```
Wykonaj teraz operację `plan` aby zobaczyć potencjalne zmiany:
```
local_file.file: Refreshing state... [id=a90efc6676b3084708cc01aefb1c27c0e114f750]
local_file.file2: Refreshing state... [id=40a30d010eaa770a9882d4c0441947ee10ab5087]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
+/- create replacement and then destroy

Terraform will perform the following actions:

  # local_file.file2 must be replaced
+/- resource "local_file" "file2" {
      ~ content              = "Hello, World! - 2023-06-28T15:55:36Z" -> (known after apply) # forces replacement
      ~ content_base64sha256 = "9lj3PBbBSfveyT3j5igVVaoWVpLnXbEk2g8++uQ2ycc=" -> (known after apply)
      ~ content_base64sha512 = "fiQN6NLTFvvbmIwM8mWAwf9IW5hPf9282g1O4rMZGs60GYME5+WwgDXSf3aLgS4jctK61iRkhw2Fg17+hQk88g==" -> (known after apply)
      ~ content_md5          = "f8f9274c0a69af60e0d20ed0966476d8" -> (known after apply)
      ~ content_sha1         = "40a30d010eaa770a9882d4c0441947ee10ab5087" -> (known after apply)
      ~ content_sha256       = "f658f73c16c149fbdec93de3e6281555aa165692e75db124da0f3efae436c9c7" -> (known after apply)
      ~ content_sha512       = "7e240de8d2d316fbdb988c0cf26580c1ff485b984f7fddbcda0d4ee2b3191aceb4198304e7e5b08035d27f768b812e2372d2bad62464870d85835efe85093cf2" -> (known after apply)
      ~ file_permission      = "0770" -> "0777" # forces replacement
      ~ id                   = "40a30d010eaa770a9882d4c0441947ee10ab5087" -> (known after apply)
        # (2 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Zwróć uwagę na komentarz Terraform co do naszego zasobu:
```
+/- create replacement and then destroy
```
Jeśli usuniemy `create_before_destroy` albo ustawimy wartość `false`, Terraform opisze zmiany w inny sposób:
```
-/+ destroy and then create replacement
```
Spróbuj w takim razie wykonać operację `apply` z `create_before_destroy` ustawionym na `true`. Po zakończeniu tej operacji spróbuj wykonać operację `plan`:
```
local_file.file2: Refreshing state... [id=c2ccffa1f447f2ef05e5f9a6a47959c47af81f1b]
local_file.file: Refreshing state... [id=a90efc6676b3084708cc01aefb1c27c0e114f750]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.file2 will be created
  + resource "local_file" "file2" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "file2.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Chyba jest coś nie tak - Terraform dopiero co pokazywał, że plik zostanie odtworzony. Po chwili chce go ponownie utworzyć? Jest to właśnie efekt uboczny `create_before_destroy`, który jest widoczny dla wielu zasobów, które nie zmieniają nazwy po utworzeniu. Ponieważ nowy plik miał być utworzony a potem jego stara wersja usunięta, Terraform usunął plik całkowicie ponieważ w lokalnym systemie plików jego nazwa się nie zmieniła. Oczywiście jeśli podalibyśmy nowy `filename` (co także spowodowałoby odtworzenie pliku), plik z nową nazwą pozostałby na swoim miejscu. Wykorzystanie `create_before_destroy` jest dość sytuacyjne - przydaje się wszędzie tam, gdzie mamy potrzebę posiadania fallbacku, nawet jeśli nie nie udało się do końca wdrożyć zmian. Przykładem może być np. redeploy bazy danych wraz z otworzeniem backupu. Jeśli nie skorzystamy z `create_before_destroy` i najpierw usuniemy starą bazę, mogłoby się okazać, że działamy przez jakiś czas bez jakiejkolwiek bazy dostępnej. Jeśli skorzystamy z `create_before_destroy` mamy pewność, że najpierw powstanie nowa instancja z odtworzonym backupem, a dopiero potem usuniemy starą. Aby jednak zadziałało to poprawnie, musimy skorzystać z typu zasobu, który nie jest identyfikowaną nazwą.
> Alternatywą dla `create_before_destroy` jest po prostu zduplikowanie konfiguracji zasobu z nowym identyfikatorem. Po wprowadzeniu zmian usuwamy stary zasób z kodu Terraform i kontynuujemy z czystą infrastrukturą.

Zobaczmy teraz w jaki sposób działa ostatni lifecycle.

## Blokowanie usuwania zasobu
Widzieliśmy już kilka razy, że pozornie niewielkie zmiany mogą wyzwolić odtworzenie zasobu. Aby zabezpieczeć się przed tą sytuacją, wykorzystamy parametr `prevent_destroy`:
```
resource "local_file" "file3" {
  filename = "file3.txt"
  content  = "Hello, World! - ${timestamp()}"
  file_permission = "0777"

  lifecycle {
    prevent_destroy = true
  }
}
```
Wykonaj operację `apply` a następnie zmień w dowolny sposób parametr `file_permission`. Następnie ponownie wykonaj operację `apply`:
```
local_file.file2: Refreshing state... [id=03634bb1e8cd3802a45511738e8ac37500b1e718]
local_file.file: Refreshing state... [id=a90efc6676b3084708cc01aefb1c27c0e114f750]
local_file.file3: Refreshing state... [id=03634bb1e8cd3802a45511738e8ac37500b1e718]
╷
│ Error: Instance cannot be destroyed
│
│   on resources.tf line 23:
│   23: resource "local_file" "file3" {
│
│ Resource local_file.file3 has lifecycle.prevent_destroy set, but the plan calls for this resource to be destroyed. To avoid this error and continue with the plan, either disable lifecycle.prevent_destroy or reduce the scope  
│ of the plan using the -target flag.
```
Jak widać, Terraform nie pozwoli nam na przeprowadzenie danej operacji ponieważ została ona zablokowana. Jeśli chcielibyśmy kontynuować z wprowadzeniem zmian dla reszty zasobów, musielibyśmy skorzystać z parametru `-target`:
```
> terraform apply -target local_file.file
local_file.file: Refreshing state... [id=a90efc6676b3084708cc01aefb1c27c0e114f750]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error message.
╵
╷
│ Warning: Applied changes may be incomplete
│
│ The plan was created with the -target option in effect, so some changes requested in the configuration may have been ignored and the output values may not be fully updated. Run the following command to verify that no other   
│ changes are pending:
│     terraform plan
│
│ Note that the -target option is not suitable for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error  
│ message.
╵

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
Jest to jednak operacja, która powinna być wykorzystywana z rozwagą aby spowodować fragmentacji pliku stanu. Zobaczmy co się stanie, jeśli z kodu Terraform usuniemy konfigurację zasobu `local_file.file3`:
```
# local_file.file3 will be destroyed
# (because local_file.file3 is not in configuration)
- resource "local_file" "file3" {
    - content              = "Hello, World! - 2023-06-28T16:09:19Z" -> null
    - content_base64sha256 = "INFq8DkDxwj4zc7hp84RJueA7AX6Pt1KoYvmv+1PCGU=" -> null
    - content_base64sha512 = "LABlrxXZKRQ997FgRiterWG02bCkYv0asRfqXgy3vPBu4Hmv2lrrnmqyHtEpsnssr01TcKfs7TXop7jI1u++Fw==" -> null
    - content_md5          = "9097f1f20f16b3a1f243f13d7b4b159a" -> null
    - content_sha1         = "03634bb1e8cd3802a45511738e8ac37500b1e718" -> null
    - content_sha256       = "20d16af03903c708f8cdcee1a7ce1126e780ec05fa3edd4aa18be6bfed4f0865" -> null
    - content_sha512       = "2c0065af15d929143df7b160462b5ead61b4d9b0a462fd1ab117ea5e0cb7bcf06ee079afda5aeb9e6ab21ed129b27b2caf4d5370a7eced35e8a7b8c8d6efbe17" -> null
    - directory_permission = "0777" -> null
    - file_permission      = "0770" -> null
    - filename             = "file3.txt" -> null
    - id                   = "03634bb1e8cd3802a45511738e8ac37500b1e718" -> null
}
```
Jak widać, w sytuacji kiedy całkowicie usuniemy nasz zasób z kodu Terraform, nie ma już niczego, co by blokowało Terraform przed jego usunięciem z naszego środowiska. W tej sytuacji należy skorzystać z zewnętrznych narzędzi (np. resource locks w przypadku środowisk chmurowych, ograniczenie uprawnień), które ograniczałyby możliwość usunięcia zasobu.