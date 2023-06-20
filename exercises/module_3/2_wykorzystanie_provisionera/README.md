# Ćwiczenie 3.2 - Wykorzystanie provisionera
## Opis
W ramach tego ćwiczenia zobaczymy jak wykorzystać możemy koncept __provisionera__ w Terraform. 

## Wykonanie ćwiczenia
Aby wykonać wszystkie operacji na poziomie __provisionera__ będziemy potrzebować w niektórych miejscach zasobów, które pozwalają na zdalne uruchamianie poleceń. W tej sytuacji aby wykonać wszystkie ćwiczenia może być wymagany dostęp do środowiska chmurowego bądź innego providera, który nie będzie darmowy. Zostaniesz o tym poinformowany w ramach opisu konkretnego zadania.

### Provisioner `file`
Provisioner `file` jest provisionerem, który kopiuje plik z lokalnej maszyny na maszynę zdalną. Aby móc z niego w pełni skorzystać, musisz zdefiniować zasób, który zezwala na zdalne połączenia z użyciem `ssh` albo `winrm`. W celu prezentacji zobaczmy co się stanie jeśli zdefiniujemy tego provisionera na poziomie lokalnego pliku:
```
resource "local_file" "file" {
  content  = "Hello, World!!!"
  filename = "hello.txt"

  provisioner "file" {
    source = "hello.txt"
    destination = "/tmp/hello.txt"

    connection {
        type     = "ssh"
        user     = "root"
        password = "1234"
        host     = "localhost"
    }
  }
}
```
Jak widzisz, provisioner wymaga zdefiniowania bloku `connection`, w ramach którego wskażesz na informacje związane z nawiązywaniem połączenia z docelowym hostem. Tego typu konfiguracja mogłaby zadziała jeśli istniałby na lokalnym komputerze użytkownik `root` z hasłem `1234` a także, jeśli otwarty byłby port `22`. W innym wypadku Terraform będzie probówać nawiązać połączenie tak długo, jak pozwala mu parametr `timeout` - domyślnie jest to 5 minut.
```
local_file.file: Provisioning with 'file'...
local_file.file: Still creating... [10s elapsed]
local_file.file: Still creating... [20s elapsed]
local_file.file: Still creating... [30s elapsed]
local_file.file: Still creating... [40s elapsed]
local_file.file: Still creating... [50s elapsed]
local_file.file: Still creating... [1m0s elapsed]
local_file.file: Still creating... [1m10s elapsed]
local_file.file: Still creating... [1m20s elapsed]
local_file.file: Still creating... [1m30s elapsed]
local_file.file: Still creating... [1m40s elapsed]
local_file.file: Still creating... [1m50s elapsed]
local_file.file: Still creating... [2m0s elapsed]
local_file.file: Still creating... [2m10s elapsed]
local_file.file: Still creating... [2m20s elapsed]
local_file.file: Still creating... [2m30s elapsed]
local_file.file: Still creating... [2m40s elapsed]
local_file.file: Still creating... [2m50s elapsed]
local_file.file: Still creating... [3m0s elapsed]
local_file.file: Still creating... [3m10s elapsed]
local_file.file: Still creating... [3m20s elapsed]
local_file.file: Still creating... [3m30s elapsed]
local_file.file: Still creating... [3m40s elapsed]
local_file.file: Still creating... [3m50s elapsed]
local_file.file: Still creating... [4m0s elapsed]
local_file.file: Still creating... [4m10s elapsed]
local_file.file: Still creating... [4m20s elapsed]
local_file.file: Still creating... [4m30s elapsed]
local_file.file: Still creating... [4m40s elapsed]
local_file.file: Still creating... [4m50s elapsed]
╷
│ Error: file provisioner error
│
│   with local_file.file,
│   on resources.tf line 5, in resource "local_file" "file":
│    5:   provisioner "file" {
│
│ timeout - last error: dial tcp [::1]:22: connectex: No connection could be made because the target machine actively refused it.
```

Jeśli chcielibyśmy zobaczyć tego provisionera w działaniu, musielibyśmy albo skonfigurować lokalny dostęp po SSH, albo skorzystać z zasobu, do którego możemy się połączyć za pomocą tego protokołu (czyli np. zdalne maszyny wirtualne, maszyny wirtualne w chmurze). Koncepcyjnie nie ma znaczenia z jakim hostem chcielibyśmy się połączyć:
* wymagany jest dostęp do hosta (host publiczny albo wewnątrz naszej sieci)
* otwarty port 22
* dostęp do docelowego katalogu zdefiniowanego w ramach parametru `destination`

> Zwróć uwagę na to, że dla SSH provisioner `file` zostanie uruchomiony w kontekście katalogu domowego użytkownika, którego zdefiniowaliśmy w ramach połączenia. Tego typu użytkownik bardzo często nie ma dostępu do katalogów spoza jego katalogu domowego.

Zanim przejdziemy dalej, omówmy zachowanie provisionerów w kontekście naszego zasobu.

### Uruchamianie provisionera
W sytuacji kiedy Twój provisioner zakończył się błędem, ponowne uruchomienie operacji `plan` albo `apply` zwróci dość nieoczekiwany rezultat:
```
local_file.file: Refreshing state... [id=a311f5574dd68ab35ad9835b3c3af70beaba1b2c]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # local_file.file is tainted, so must be replaced
-/+ resource "local_file" "file" {
      ~ content_base64sha256 = "hrtK2UwDjk8HwK6jyazyfNt7hxvsvvg2nogqRIJIZ2M=" -> (known after apply)
      ~ content_base64sha512 = "EhiffylLC5tcNHAojzM/KI1T3MmuYpx84tQmfyTIvnNRuoxZQYhDoZizKFBY1ElP5fNIolGNepNk9tL7mS1rHg==" -> (known after apply)
      ~ content_md5          = "1b42ffc46823f2589a79b56749897f79" -> (known after apply)
      ~ content_sha1         = "a311f5574dd68ab35ad9835b3c3af70beaba1b2c" -> (known after apply)
      ~ content_sha256       = "86bb4ad94c038e4f07c0aea3c9acf27cdb7b871becbef8369e882a4482486763" -> (known after apply)
      ~ content_sha512       = "12189f7f294b0b9b5c3470288f333f288d53dcc9ae629c7ce2d4267f24c8be7351ba8c59418843a198b3285058d4494fe5f348a2518d7a9364f6d2fb992d6b1e" -> (known after apply)
      ~ id                   = "a311f5574dd68ab35ad9835b3c3af70beaba1b2c" -> (known after apply)
        # (4 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```
Terraform oznaczył nasz zasób jako __tainted__. Oznacza to, że nie jest on w stanie potwierdzić, czy stan zasobu jest właściwy czy nie. Aby wybrnać z tej sytuacji Terraform postanawia odtworzyć zasób. Jest to jeden z powodów dla których użycie provisionera nie jest rekomendowane - w sytuacji kiedy provisioner się nie wykona możemy przypadkowo go odtworzyć przez oznaczenie zasobu jako __tainted__. Blokuje to dodatkowo wdrożenie - dlatego też Terraform dostarcza operację `untaint`:
```
terraform untaint local_file.file
```
W tym momencie ponowne uruchomienie `plan` albo `apply` nie będzie już raportowało błędu:
```
local_file.file: Refreshing state... [id=a311f5574dd68ab35ad9835b3c3af70beaba1b2c]

No changes. Your infrastructure matches the configuration.
```
Zwróć uwagę jednak na jeszcze jedno specyficzne zachowanie provisionerów - jeśli nie wprowadzisz zmian do konfiguracji konkretnego zasobu, provisioner nie zostanie wykonany. Nie pomaga nawet zmiana konfiguracji połączenia. Spróbuj we własnym zakresie zmienić użytkownika bądź hasło w ramach konfiguracji bloku `connection`. Pomimo wprowadzenia tych zmian, provisioner nie zostanie wykonany.

### Provisioner `local_exec`
W przeciwieństwie do `file` oraz `remote_exec`, provisioner `local_exec` służy do uruchamiania komend w ramach lokalnego środowiska. Nie musimy więc dla niego definiować bloku `connection`, który wskaże protokół, użytkownika czy też hasło:
```
resource "local_file" "file2" {
  content  = "Hello, World"
  filename = "hello2.txt"

  provisioner "local-exec" {
    command = "echo %DATA1% %DATA2% >> env_vars.txt"

    environment = {
      DATA1 = "bar"
      DATA2 = 1
    }
  }
}
```
W momencie kiedy wywołasz operację `apply`, w lokalnym katalogu roboczym pojawią się dwa nowe artefakty:
* plik `hello2.txt`
* plik `env_vars.txt` zawierający wartości zmiennych środowiskowych `DATA1` oraz `DATA2`

Zwróć jednak uwagę, że komenda zdefiniowana w ramach parametru `command` nie zadziała w każdym wypadku. Powyższy przykład jest właściwy dla systemu operacyjnego Windows. Dla systemu Linux, komenda powinna być zdefiniowana w następujący sposób:
```
command = "echo $DATA1 $DATA2 >> env_vars.txt"
```
Wynika to z różnic na poziomie interpretacji komend w różnych systemach operacyjnych.
> Ponieważ komendy mogą być interpretowane za pomocą różnych interpreterów, `local_exec` może być dość kłopotliwy pod kątem "przenaszalności" pomiędzy środowiskami.

Pomimo pewnych ograniczeń, `local_exec` bywa przydatny jeśli chcemy np. po zaaplikowaniu zmian lokalnie wywołać dodatkowe narzędzie, które wykona akcję poza standardowym workflow Terraforma.

### Provisioner `remote_exec`
Provisioner który działa bardzo podobnie do `local_exec` to `remote_exec`, który różni się tylko tym, że zdefiniowane w nim polecenia są wykonywane na poziomie zdalnej maszyny. Można powiedzieć, że łączy on funkcjonalności omówionych już provisionerów:
* pozwala na łączenie się ze zdalną maszyną
* pozwala na wykonanie dodatkowych operacji

Dość ciekawym rozwiązaniem jest łączenie provisionera `file` razem z `remote_exec`:
```
resource "local_file" "file2" {
  content  = "Hello, World"
  filename = "hello2.txt"

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh arg1 arg2",
    ]
  }
}
```
Z czego wynika takie podejście? Cóż, okazuje się, że provisioner `remote_exec`, pomimo posiadania parametru `script`, nie pozwala na przekazanie parametrów, który przez skrypt mogłyby być wymagane:
```
resource "local_file" "file2" {
  content  = "Hello, World"
  filename = "hello2.txt"

  provisioner "remote-exec" {
    script = "/tmp/script.sh arg1 arg2" -> TO NIE ZADZIAŁA
  }
}
```
Aby obejść to ograniczenie, rekomendowanym podejściem jest wykorzystanie `file` do skopiowania skryptu a następnie `remote_exec`, w ramach którego zdefiniujemy parametr `inline` do jego wykonania.

> Zamiast `script` provisioner `remote_exec` przyjmuje także parametr `scripts`. Służy on do przekazania listy skryptów do wykonania. Wykonane są one potem zgodnie z kolejnością zdefiniowania w kodzie. Pamiętaj jednocześnie o tym, że parametry `inline`, `script` oraz `scripts` nie mogą współistnieć - trzeba wybrać jeden, którym się posłużymy.

Do definiowania sposobu oraz parametrów połączenia służy blok `connection` umówiony w ramach provisionera `file`. 

### Operator `self`
W ramach provisionerów chcemy czasem odnieść się do właściwości obiektu na poziomie którego definiujemy provisionera. Aby tego dokonać wykorzystać możemy operator `self`:
```
connection {
  type     = "ssh"
  user     = "root"
  password = var.connection_password
  host     = self.network.public_ip
}
```
Powyższy przykład pokazuje w jaki sposób korzystamy z `self`. Zakładając, że obiekt (zasób) posiada właściwość `network.public_ip`, możemy ją wykorzystać do wyciągnięcia publicznego adresu IP, który potem mógłby byc użyty w ramach provisionerów `file` albo `remote_exec`. Jest to przydatne jesli tego adresu nie znamy na poziomie zmiennych wejściowych - z powodu ograniczeń technicznych provisioner nie może tworzyć referencji do nadrzędnego dla niego zasobu.