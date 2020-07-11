locals {
  vnet_address_prefix   = "10.0.0.0/16"
  subnet_address_prefix = ["10.0.0.0/24"]
  tags = {"indicate" = "${var.tag}"}
}

provider "azurerm" {
   features {}
}

resource "azurerm_resource_group" "common" {
 name     = "rg-dev-${var.product_name}-${var.username}"
 location = "westeurope"
}

resource "azurerm_availability_set" "common" {
 name                         = "avset-dev-${var.product_name}-${var.username}"
 location                     = azurerm_resource_group.common.location
 resource_group_name          = azurerm_resource_group.common.name
 platform_fault_domain_count  = 1
 platform_update_domain_count = 1
 managed                      = true
}

resource "random_string" "password" {
 length = 32
 special = true
}

resource "random_id" "pseudo" {
  keepers = {
    resource_group = azurerm_resource_group.common.name
    location       = azurerm_resource_group.common.location
  }
  byte_length = 4
}

resource "azurerm_virtual_network" "common" {
 name                = "vnet-dev-${var.product_name}-${var.username}"
 address_space       = ["${local.vnet_address_prefix}"]
 location            = azurerm_resource_group.common.location
 resource_group_name = azurerm_resource_group.common.name
}

resource "azurerm_subnet" "common" {
 name                 = "snet-dev-${var.product_name}-${var.username}"
 resource_group_name  = azurerm_resource_group.common.name
 virtual_network_name = azurerm_virtual_network.common.name
 address_prefixes      = local.subnet_address_prefix
}


resource "azurerm_network_security_group" "common" {
  name                         = "nsg-${var.product_name}-${var.username}"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.common.name

  security_rule {
    name                       = "Port_OFFICE_IN"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port_OFFICE_OUT"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "lrepo"
  }
}

resource "azurerm_subnet_network_security_group_association" "manager_common" {
  subnet_id                 = azurerm_subnet.common.id
  network_security_group_id = azurerm_network_security_group.common.id
}


resource "azurerm_storage_account" "diagnostics" {
  name                     = "swarmdiagnostics${random_id.pseudo.hex}"
  location                 = azurerm_resource_group.common.location
  resource_group_name      = azurerm_resource_group.common.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
  tags                     = local.tags
}


#--- Importing module with VM creation ---

module "manager" {
  source = "./manager"

  name                = "manager-${var.product_name}-${var.username}"
  count_managers      = var.count_managers

  vm_size             = var.vm_size
  image_sku           = var.image_sku
  image_offer         = var.image_offer
  image_publisher     = var.image_publisher

  location            = var.location
  resource_group_name = azurerm_resource_group.common.name

  username            = var.username
  pwd                 = random_string.password.result
  ssh_key             = var.ssh_key
  ssh_port            = var.ssh_port

  availability_set_id = azurerm_availability_set.common.id

  subnet_id           = azurerm_subnet.common.id
  storage_type        = var.storage_type
  tags                = local.tags
}



module "worker" {
  source = "./worker"

  name                = "worker-${var.product_name}-${var.username}"
  count_managers      = var.count_workers

  vm_size             = var.vm_size
  image_sku           = var.image_sku
  image_offer         = var.image_offer
  image_publisher     = var.image_publisher

  location            = var.location
  resource_group_name = azurerm_resource_group.common.name

  username            = var.username
  pwd                 = random_string.password.result
  ssh_key             = var.ssh_key
  ssh_port            = var.ssh_port

  availability_set_id = azurerm_availability_set.common.id

  subnet_id           = azurerm_subnet.common.id
  storage_type        = var.storage_type
  tags                = local.tags
}


data "template_file" "inventory" {
  template = file("config/inventory.yml.tpl")

  vars = {
    managers = join("\n", formatlist("manager_%s ansible_port=22 ansible_host=%s", module.manager.manager_host, module.manager.manager_ips))
    workers  = join("\n", formatlist("worker_%s ansible_port=22 ansible_host=%s", module.worker.worker_host, module.worker.worker_ips))
  }
}

resource "local_file" "hosts" {
  content  = data.template_file.inventory.rendered
  filename = "../playbooks/hosts"
}

data "template_file" "vault" {
  template = file("config/vault.yml.tpl")

  vars = {
    vm_managers_become_password = join("\n", formatlist("vault_ssh_manager=%s", module.manager.manager_passwd))
    vm_workers_become_password = join("\n", formatlist("vault_ssh_worker=%s", module.worker.worker_passwd))
  }
}

resource "local_file" "vault" {
  content  = data.template_file.vault.rendered
  filename = "../playbooks/vault.yml"

  provisioner "local-exec" {
    command="ansible-vault encrypt ../playbooks/vault.yml --vault-password-file=../vault-password.txt"
  }
}




