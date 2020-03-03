locals {
  vnet_address_prefix   = "10.0.0.0/16"
  subnet_address_prefix = "10.0.0.0/24"
  tags = {"indicate" = "${var.tag}"}
}

resource "azurerm_resource_group" "common" {
 name     = "rg-dev-${var.product_name}-${var.username}"
 location = "westeurope"
}

resource "azurerm_availability_set" "common" {
 name                         = "avset-dev-${var.product_name}-${var.username}"
 location                     = "${azurerm_resource_group.common.location}"
 resource_group_name          = "${azurerm_resource_group.common.name}"
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
    resource_group = "${azurerm_resource_group.common.name}"
    location       = "${azurerm_resource_group.common.location}"
  }
  byte_length = 4
}

resource "azurerm_virtual_network" "common" {
 name                = "vnet-dev-${var.product_name}-${var.username}"
 address_space       = ["${local.vnet_address_prefix}"]
 location            = "${azurerm_resource_group.common.location}"
 resource_group_name = "${azurerm_resource_group.common.name}"
}

resource "azurerm_subnet" "common" {
 name                 = "snet-dev-${var.product_name}-${var.username}"
 resource_group_name  = "${azurerm_resource_group.common.name}"
 virtual_network_name = "${azurerm_virtual_network.common.name}"
 address_prefix       = "${local.subnet_address_prefix}"
}

resource "azurerm_storage_account" "diagnostics" {
  name                     = "swarmdiagnostics${random_id.pseudo.hex}"
  location                 = "${azurerm_resource_group.common.location}"
  resource_group_name      = "${azurerm_resource_group.common.name}"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  tags                     = "${local.tags}"
}


#--- Importing module with VM creation ---

data "template_file" "client_config" {
  template = "${file("${path.module}/config/cloudconfig.yml.tpl")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "cloudconfig.yml.tpl"
    content_type = "text/cloud-config"
    content      = "${data.template_file.client_config.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "baz"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "ffbaz"
  }
}

module "manager" {
  source = "./manager"

  name                = "manager-${var.product_name}-${var.username}"
  count_managers      = "${var.count_managers}"

  vm_size             = "${var.vm_size}"
  image_sku           = "${var.image_sku}"
  image_offer         = "${var.image_offer}"
  image_publisher     = "${var.image_publisher}"

  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.common.name}"

  username            = "${var.username}"
  pwd                 = "${random_string.password.result}"
  ssh_key             = "${var.ssh_key}"
  ssh_port            = "${var.ssh_port}"

  availability_set_id = "${azurerm_availability_set.common.id}"

  subnet_id           = "${azurerm_subnet.common.id}"
  storage_type        = "${var.storage_type}"
  tags                = "${local.tags}"
  cloud_config        = "${base64encode(data.template_file.client_config.rendered)}"
}



module "worker" {
  source = "./worker"

  name                = "worker-${var.product_name}-${var.username}"
  count_managers      = "${var.count_workers}"

  vm_size             = "${var.vm_size}"
  image_sku           = "${var.image_sku}"
  image_offer         = "${var.image_offer}"
  image_publisher     = "${var.image_publisher}"

  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.common.name}"

  username            = "${var.username}"
  pwd                 = "${random_string.password.result}"
  ssh_key             = "${var.ssh_key}"
  ssh_port            = "${var.ssh_port}"

  availability_set_id = "${azurerm_availability_set.common.id}"

  subnet_id           = "${azurerm_subnet.common.id}"
  storage_type        = "${var.storage_type}"
  tags                = "${local.tags}"
  cloud_config        = "${base64encode(data.template_file.client_config.rendered)}"
}


data "template_file" "inventory" {
  template = "${file("config/inventory.yml.tpl")}"


  vars = {
    managers = "${join("\n", module.manager.myips)}"
    workers  = "${join("\n", module.worker.myips)}"
  }
}




