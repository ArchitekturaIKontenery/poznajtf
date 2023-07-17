# Ćwiczenie 6.1 - Blok `dynamic`
## Opis
W ramach tego ćwiczenia nauczysz się jak pracować z blokiem `dynamic` do pracy z dynamiczną konfiguracją.

## Wykonanie ćwiczenia
Ćwiczenie zaprezentuję z użyciem usługi Azure Storage, co jest związane z koniecznością wykorzystania zasobu, który definiuje w Terraform dodatkowe bloki. Te same czynności, które zostaną tutaj zaprezentowane, mogą być wykonane z użyciem większości dostępnych providerów (np. AWS, GCP czy Kubernetes).

## Zdefiniowanie zasobu
Zaczynamy od zdefiniowania podstawowej konfiguracji naszego zasobu:
```
resource "azurerm_resource_group" "rg" {
  name     = "rg-poznaj-terraform"
  location = "westeurope"
}

resource "azurerm_storage_account" "storage" {
  name                     = "storagepoznajtf"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```
Powyższy kod utworzy w Azure dwa zasoby:
* grupę zasobów
* Azure Storage Account, która zostanie umieszczona w ramach zdefiniowanej grupy zasobów

Po wykonaniu operacji `apply`, zasoby zostaną utworzone w ramach zdefiniowanej subskrypcji.

## Definiowanie bloku `dynamic`
Blok `dynamic` jest używany w sytuacji kiedy chcemy zdefiniować konfigurację zasobu, która będzie zmieniać się w zależności od przekazanych parametrów. Zaprezentujemy to na przykładzie definiowania reguł sieciowych dla Azure Storage. W normalnej sytuacji, definicja tego zasobu, która zawiera pojedynczą regułę sieciową będzie wyglądać np. tak:
```
resource "azurerm_resource_group" "rg" {
  name     = "rg-poznaj-terraform"
  location = "westeurope"
}

resource "azurerm_storage_account" "storage" {
  name                     = "storagepoznajtf"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["10.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtnetname"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}
```
W ramach powyższej konfiguracji definiujemy dwa dodatkowe zasoby (sieć wirtualna + subnet) a następnie definiujemy blok `network_rules`, który zawiera dodatkowe informacje. Co jednak jeśli chcielibyśmy wytworzyć kilka takich bloków? Omawiane wcześniej pętle `count` oraz `for_each` definiowane są na poziomie konfiguracji zasobu a nie jego bloków. Z pomocą jednak przychodzi nam blok `dynamic`:
```
resource "azurerm_storage_account" "storage" {
  name                     = "storagepoznajtf"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  dynamic "network_rules" {
    content {
      default_action             = "Deny"
      ip_rules                   = ["10.0.0.1"]
      virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
    }
  }
}
```
Definicja bloku `dynamic` składa się z dwóch elementów:
* `dynamic` "<nazwa-bloku>
* blok `content`

Zauważ, że blok `dynamic` posiada identyczną nazwę jak oryginalny blok użyty w ramach naszej konfiguracji. Wynika to z tego, że może być on traktowany jako szablon, który następnie jest materializowany jako docelowy obiekt. Blok `content` natomiast posiada wszystkie pola, które były do użycia standardowo w bloku `network_rules`. Wykonanie teraz operacji `plan` nie dam jednak oczekiwanego rezultatu:
```
Error: Missing required argument
│
│   on resources.tf line 13, in resource "azurerm_storage_account" "storage":
│   13:   dynamic "network_rules" {
│
│ The argument "for_each" is required, but no definition was found.
```
Wychodzi na to, że musimy dodać zmienną wejściową aby dopełnić konfiguracji.

## Definiowanie zmiennej i wykorzystanie
Stworzymy teraz plik `variables.tf`, gdzie dodamy nową definicję zmiennej:
```
variable "network_rules" {
    type = list(object({
        default_action             = string
        ip_rules                   = list(string)
        virtual_network_subnet_ids = optional(list(string))
    }))
    default = [{
        default_action             = "Deny"
        ip_rules                   = ["10.0.0.1"]
    }]
}
```
Zmienna ta będzie kolekcją obiektów, które mogą być użyte w ramach bloku `network_rules`. Naprawmy teraz definicje naszego bloku `dynamic`:
```
dynamic "network_rules" {
    for_each = var.network_rules

    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
    }
}
```
Od tego momentu zasob Azure Storage będzie tworzony z dynamicznie konfigurowanymi regułami sieciowymi. Zanim przejdziemy dalej, zwróć uwagę na jeden szczegół. Przy standardowych pętlach `for_each`, dostęp do wartości danego elementu kolekcji odbywał się za pomocą `each.value`. Tym razem rolę `each` przejmuje nazwa bloku `dynamic`. Liczba utworzonych bloków `network_rules` będzie zależeć od ilości elementu w kolekcji przekazywanej za pomocą zmiennej `network_rules`. Wynikowy plan wdrożenia wyglądać będzie w następujący sposób:
```
# azurerm_storage_account.storage will be updated in-place
~ resource "azurerm_storage_account" "storage" {
    id                                = "/subscriptions/.../resourceGroups/rg-poznaj-terraform/providers/Microsoft.Storage/storageAccounts/storagepoznajtf"
    name                              = "storagepoznajtf"
    tags                              = {}
    # (37 unchanged attributes hidden)

    ~ network_rules {
        ~ default_action             = "Allow" -> "Deny"
        ~ ip_rules                   = [
            + "10.0.0.1",
        ]
        ~ virtual_network_subnet_ids = [] -> (known after apply)
        # (1 unchanged attribute hidden)
    }

    # (3 unchanged blocks hidden)
}
```
Pamiętaj jednak, że bloki `dynamic` mogą znacznie utrudnić utrzymanie konfiguracji pod kontrolą, szczególnie jeśli tworzymy wiele elementów w ten sposób. Szczególnie kłopotliwa może być konieczność przeniesienia niektórych elementów w pliku stanu (używając do tego polecenia `state mv` albo bloku `moved`).