# Ćwiczenie 8.1 - Testowanie z użyciem Terratest
## Opis
W ramach tego ćwiczenia nauczysz się w jaki sposób testować swój kod z użyciem Terratest.

## Wykonanie ćwiczenia
Aby skorzystać z Terratest wymagane będzie zainstalowanie Go (https://go.dev).

## Infrastruktura do testowania
W swoim katalogu roboczym utwórz plik `resources.tf`, w ramach którego umieść poniższy fragment kodu:
```
resource "local_file" "test" {
  filename = "test.txt"
  content  = "test"
}
```
Utwórz także lokalny katalog `tests` gdzie będziemy dodawać testy do naszej infrastruktury.

## Pierwszy test
W katalogu `tests` utwórz plik `first_test.go` wraz z następującym fragmentem kodu:
```
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLocalFile(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "filename")
	assert.Equal(t, "test.txt", output)
}
```
Następnie wykonaj poniższe komendy aby zainicjalizować lokalny moduł a także jego zależności:
```
go mod init poznajterraform.io/m
go get github.com/gruntwork-io/terratest/modules/terrafor
```
Na koniec uruchom testy:
```
go test -v
```
Wynikiem działania powyższej komendy powinien być następujący output:
```
=== RUN   TestLocalFile
TestLocalFile 2023-08-01T13:01:39+02:00 retry.go:91: terraform [init -upgrade=false]
TestLocalFile 2023-08-01T13:01:39+02:00 logger.go:66: Running command terraform with args [init -upgrade=false]
TestLocalFile 2023-08-01T13:01:39+02:00 logger.go:66: 
TestLocalFile 2023-08-01T13:01:39+02:00 logger.go:66: Initializing the backend...
TestLocalFile 2023-08-01T13:01:39+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:39+02:00 logger.go:66: Initializing provider plugins...
TestLocalFile 2023-08-01T13:01:39+02:00 logger.go:66: - Finding latest version of hashicorp/local...
TestLocalFile 2023-08-01T13:01:40+02:00 logger.go:66: - Installing hashicorp/local v2.4.0...
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: - Installed hashicorp/local v2.4.0 (signed by HashiCorp)
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: 
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: Terraform has created a lock file .terraform.lock.hcl to record the provider
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: selections it made above. Include this file in your version control repository
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: so that Terraform can guarantee to make the same selections by default when
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: you run "terraform init" in the future.
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: Terraform has been successfully initialized!
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: You may now begin working with Terraform. Try running "terraform plan" to see
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: any changes that are required for your infrastructure. All Terraform commands
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: should now work.
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: If you ever set or change modules or backend configuration for Terraform,
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: rerun this command to reinitialize your working directory. If you forget, other
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: commands will detect it and remind you to do so if necessary.
TestLocalFile 2023-08-01T13:01:41+02:00 retry.go:91: terraform [apply -input=false -auto-approve -lock=false]
TestLocalFile 2023-08-01T13:01:41+02:00 logger.go:66: Running command terraform with args [apply -input=false -auto-approve -lock=false]
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: 
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Terraform used the selected providers to generate the following execution
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: plan. Resource actions are indicated with the following symbols:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:   + create
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Terraform will perform the following actions:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:   # local_file.test will be created
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:   + resource "local_file" "test" {
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + content              = "test"
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + content_base64sha256 = (known after apply)
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + content_base64sha512 = (known after apply)
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + content_md5          = (known after apply)
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + content_sha1         = (known after apply)
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + content_sha256       = (known after apply)
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + content_sha512       = (known after apply)
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + directory_permission = "0777"
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + file_permission      = "0777"
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + filename             = "test.txt"
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:       + id                   = (known after apply)
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:     }
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Plan: 1 to add, 0 to change, 0 to destroy.
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Changes to Outputs:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:   + filename = "test.txt"
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: local_file.test: Creating...
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: local_file.test: Creation complete after 0s [id=a94a8fe5ccb19ba61c4c0873d391e987982fbbd3]
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: 
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Outputs:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: filename = "test.txt"
TestLocalFile 2023-08-01T13:01:43+02:00 retry.go:91: terraform [output -no-color -json filename]
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Running command terraform with args [output -no-color -json filename]
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: "test.txt"
TestLocalFile 2023-08-01T13:01:43+02:00 retry.go:91: terraform [destroy -auto-approve -input=false -lock=false]
TestLocalFile 2023-08-01T13:01:43+02:00 logger.go:66: Running command terraform with args [destroy -auto-approve -input=false -lock=false]
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: local_file.test: Refreshing state... [id=a94a8fe5ccb19ba61c4c0873d391e987982fbbd3]
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: 
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: Terraform used the selected providers to generate the following execution
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: plan. Resource actions are indicated with the following symbols:
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:   - destroy
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: Terraform will perform the following actions:
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:   # local_file.test will be destroyed
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:   - resource "local_file" "test" {
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - content              = "test" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - content_base64sha256 = "n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - content_base64sha512 = "7iaw3Ur350mqGo7jwQrpkj9hiYB3Lkc/iBml1JQODbJ6wYX4oOHV+E+IvIh/1nsUNzLDBMxfqa2Ob1f1ACio/w==" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - content_md5          = "098f6bcd4621d373cade4e832627b4f6" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - content_sha1         = "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - content_sha256       = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - content_sha512       = "ee26b0dd4af7e749aa1a8ee3c10ae9923f618980772e473f8819a5d4940e0db27ac185f8a0e1d5f84f88bc887fd67b143732c304cc5fa9ad8e6f57f50028a8ff" -> null    
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - directory_permission = "0777" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - file_permission      = "0777" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - filename             = "test.txt" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:       - id                   = "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:     }
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: Plan: 0 to add, 0 to change, 1 to destroy.
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: Changes to Outputs:
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:   - filename = "test.txt" -> null
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: local_file.test: Destroying... [id=a94a8fe5ccb19ba61c4c0873d391e987982fbbd3]
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: local_file.test: Destruction complete after 0s
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: 
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66: Destroy complete! Resources: 1 destroyed.
TestLocalFile 2023-08-01T13:01:44+02:00 logger.go:66:
--- PASS: TestLocalFile (4.49s)
PASS
ok      poznajterraform.io/m    5.088s
```
Spróbujmy teraz zagłębić się w napisany kod aby poznać każdą z wykonanych komend.

## Analiza kodu
Pisanie testu rozpoczynamy od zdefiniowania opcji dla Terraform, między innymi katalogu roboczego z naszym kodem:
```
terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})
```
Nasz kod wykorzystuje operator `defer` aby na końcu wykonania testu wykonać operację `destroy` dzięki czemu każdorazowo startujemy od tego samego stanu:
```
defer terraform.Destroy(t, terraformOptions)
```
Poniższy fragment kodu pozwala nam na zainicjalizowanie konfiguracji oraz aplikację zmian:
```
terraform.InitAndApply(t, terraformOptions)
```
Dodatkowo możesz też sprawdzić, czy Twój test jest idempotentny:
```
terraform.ApplyAndIdempotent(t, terraformOptions)
```
Powyższy (opcjonalny) fragment kodu zwróci błąd jeśli druga operacja `apply` zwróci więcej niż 0 zmian.
Na koniec pobieramy output wykonanych zmian i sprawdzamy, czy zmienna wyjściowa `filename` zawiera oczekiwaną wartość:
```
output := terraform.Output(t, terraformOptions, "filename")
assert.Equal(t, "test.txt", output)
```
Zwróć uwagę na to, że ten test operuje na poziomie lokalnej infrastruktury, nic jednak nie stoi na przeszkodzie aby wykorzystać np. paczkę `http_helper` stworzoną dla Terratest aby po zaaplikowaniu zmian spróbować potwierdzić czy infrastruktura faktycznie działa:
```
http_helper.HttpGetWithRetry(t, url, nil, <http-status-code>, "<oczekiwana-odpowiedź-http>", 30, 5*time.Second)
```