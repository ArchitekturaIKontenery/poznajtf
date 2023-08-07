# Ćwiczenie 8.3 - Wykorzystanie Infracost
## Opis
W ramach tego ćwiczenia nauczysz się w jaki sposób pracować z narzędziem Infracost.

## Wykonanie ćwiczenia
Infracost jest narzędziem, które może nam posłużyć do estymacji kosztów infrastruktury opisanej z użyciem Terraform. Aby zacząć pracę z narzędziem, pobierz Infracost ze strony - https://www.infracost.io/docs/#quick-start.

## Praca z Infracost
Infracost potrafi estymować koszt infrastruktury na podstawie wewnętrznych reguł określających koszt oraz sposób kalkulacji zasobów. Na ten moment głównymi integracjami Infracost są dostawcy chmurowi:
* Azure
* AWS
* GCP

Dla przykładu - powiedzmy, że tworzymy infrastrukturę w Azure opisaną poniższym kodem:
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-infracost"
  location = "westeurope"
}

resource "azurerm_container_registry" "acr" {
  name                     = "acrinfracost"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-infracost"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/20"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-infracost"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-infracost"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Poznajterraform123"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
```
Aby obliczyć miesięczny koszt takiej infrastruktury musielibyśmy posiłkować się kalkulatorem kosztów. Jest to możliwe do zrobienia, jednak konfiguracja zasobów może zmieniać się dość dynamicznie, dlatego też to rozwiązanie jest rzadko stosowane. Automatyczna kalkulacja kosztów z użyciem Infracost jest czymś, co zdecydowanie łatwiej byłoby nam wykorzystać.

Aby obliczyć koszt powyższej konfiguracji możemy wykonać poniższy polecenie:
```
infracost breakdown --path .
```
Parametr `--path` wskazuje w przykładzie na lokalny katalog roboczy. Wynik działania tego polecenia wyglądać będzie w poniższy sposób:
```
Evaluating Terraform directory at .
  ✔ Downloading Terraform modules  
  ✔ Evaluating Terraform directory
  ✔ Retrieving cloud prices to calculate costs
Name                                                    Monthly Qty  Unit                      Monthly Cost

 azurerm_container_registry.acr
 ├─ Registry usage (Basic)                                        30  days                             $5.00
 ├─ Storage (over 10GB)                           Monthly cost depends on usage: $0.10 per GB

 azurerm_virtual_machine.vm
 ├─ Instance usage (pay as you go, Standard_B1s)                 730  hours                            $8.76
 ├─ Ultra disk reservation (if unattached)        Monthly cost depends on usage: $5.69 per vCPU
 └─ storage_os_disk
    ├─ Storage (S4, LRS)                                           1  months                           $1.54
    └─ Disk operations                            Monthly cost depends on usage: $0.0005 per 10k operations

 OVERALL TOTAL                                                                                        $15.29
──────────────────────────────────
6 cloud resources were detected:
∙ 2 were estimated, all of which include usage-based costs, see https://infracost.io/usage-file
∙ 4 were free, rerun with --show-skipped to see details
```

## Kalkulacja na podstawie planu
Jeśli wskażemy Infracost na plik stanu zamiast katalog roboczy, estymacja kosztów zostanie wykonana w kontekście planowanych zmian zamiast całej konfiguracji:
```
terraform plan -out tfplan.binary
terraform show -json tfplan.binary > plan.json
infracost breakdown --path plan.json
```
Pozwala to sprawdzanie kosztu w sposób ciągły bazując na zmianach wykrytych przez Terraform:
```
infracost breakdown --path tfplan.binary
Detected Terraform plan binary file at tfplan.binary
  ✔ Running terraform show
  ✔ Extracting only cost-related params from terraform  
  ✔ Retrieving cloud prices to calculate costs

Project: ArchitekturaIKontenery/poznajtf-wip/exercises\module_8\3_infracost\tfplan.binary

 Name                                                    Monthly Qty  Unit                      Monthly Cost

 azurerm_container_registry.acr
 ├─ Registry usage (Basic)                                        30  days                             $5.00
 ├─ Storage (over 10GB)                           Monthly cost depends on usage: $0.10 per GB
 └─ Build vCPU                                    Monthly cost depends on usage: $0.0001 per seconds

 azurerm_linux_virtual_machine.example
 ├─ Instance usage (pay as you go, Standard_B2s)                 730  hours                           $35.04
 └─ os_disk
    ├─ Storage (S4, LRS)                                           1  months                           $1.54
    └─ Disk operations                            Monthly cost depends on usage: $0.0005 per 10k operations

 OVERALL TOTAL                                                                                        $41.57
──────────────────────────────────
6 cloud resources were detected:
∙ 2 were estimated, all of which include usage-based costs, see https://infracost.io/usage-file
∙ 4 were free, rerun with --show-skipped to see details
```