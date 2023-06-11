# Ćwiczenie 1.1 - Konfiguracja providerów
## Opis
W ramach tego ćwiczenia skupimy się na zdefiniowaniu konfiguracji Terraform, w ramach której określimy wykorzystywanych providerów. 

## Wykonanie ćwiczenia
W ramach rozpoczęcia prac z konfiguracją Terraform, pierwszym blokiem, który musi być wytworzony, jest blok `terraform`:
```
terraform {
}
```
Blok ten może być umieszczony w dowolnym pliku z rozszerzeniem `.tf`. Na potrzeby tego ćwiczenia blok `terraform` umieścimy w pliku `provider.tf`.
> Kwestia nazewnictwa plików Terraform jest zależna od ustaleń Twojego zespołu bądź polityk Twojej organizacji. Z technicznego punktu widzenia nie ma znaczenia jak pliki się nazywają - Terraform zawsze interpretuje wszystkie pliki `.tf` z katalogu roboczego w Twoim terminalu.

### Określanie providerów w kodzie
Konfiguracja, którą utworzymy, składać się będzie z 3 różnych providerów:
* `azurerm`
* `aws`
* `google`

Przykładowy kod Terraform może wyglądać tak jak poniżej:
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.60.0"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 4.60"
    }
  }
}
```

Zwróć uwagę na sposób w jaki określamy naszego providera:
```
<lokalna-nazwa> = {
    source  = "<lokalizacja-providera>"
    version = "<version-constraint>"
}
```

W kontekście naszej konfiguracji wskazujemy na lokalizację providerów określoną jako `hashicorp`. Jest to publicznie dostępny rejestr modułów oraz providerów, do którego każdy ma dostep. W ramach następnych lekcji oraz ćwiczeń nauczysz się w jaki sposób można wykorzystać prywatne rejestry.

Póki co nie zwracaj uwagę na zdefiniowane wersje providerów - są to _version constraints_, o których będziemy mówić więcej w ramach kolejnych ćwiczeń.

### Weryfikacja kodu Terraform
Aby upewnić się, że z punktu widzenia kodu wszystko jest w porządku, spróbujmy zainicjalizować konfigurację:
```
terraform init
```

Jako rezultat tej komendy powinniśmy otrzymać następującą informację:
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/google versions matching ">= 4.60.0"...
- Finding hashicorp/aws versions matching "~> 4.0"...
- Finding hashicorp/azurerm versions matching "3.60.0"...
- Installing hashicorp/google v4.68.0...
- Installed hashicorp/google v4.68.0 (signed by HashiCorp)
- Installing hashicorp/aws v4.67.0...
- Installed hashicorp/aws v4.67.0 (signed by HashiCorp)
- Installing hashicorp/azurerm v3.60.0...
- Installed hashicorp/azurerm v3.60.0 (signed by HashiCorp)

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

Od tego momentu jesteśmy gotowi do pracy z naszą infrastrukturą w kodzie!