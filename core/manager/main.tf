resource "azurerm_public_ip" "common" {
  count                        = var.count_managers
  name                         = "pip-dev-${var.username}-manager-counter${count.index}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  allocation_method            = "Static"
}

resource "azurerm_network_interface" "common" {
  count                     = var.count_managers
  name                      = "eth-dev-${var.username}-manager-counter${count.index}"
  location                  = var.location
  resource_group_name       = var.resource_group_name

  ip_configuration {
   name                          = "nic-dev-${var.username}-manager-counter${count.index}"
   subnet_id                     = var.subnet_id
   private_ip_address_allocation = "dynamic"
   public_ip_address_id          = element(azurerm_public_ip.common.*.id, count.index)
  }
}


resource "azurerm_virtual_machine" "common" {
  count                 = var.count_managers
  name                  = "vm-dev-${var.username}-manager-counter${count.index}"
  location              = var.location
  availability_set_id   = var.availability_set_id
  resource_group_name   = var.resource_group_name
  network_interface_ids = ["${element(azurerm_network_interface.common.*.id, count.index)}"]
  vm_size               = var.vm_size

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-dev-${var.username}-manager-counter${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.storage_type
  }

  # Optional data disks
  storage_data_disk {
    name              = "datadisk-dev-${var.username}-manager-counter${count.index}"
    managed_disk_type = var.storage_type
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.username}-manager-common-env"
    admin_username = var.username
    admin_password = var.pwd
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path = "/home/${var.username}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  connection {
    type     = "ssh"
    user     = var.username
    password = var.pwd
    host     = element(azurerm_public_ip.common[*].ip_address, count.index)
  }

  # For sync time in all hosts (legacy!)
//  provisioner "file" {
//    source      = "config/ntp.conf"
//    destination = "/tmp/ntp.conf"
//
//    connection {
//      type     = "ssh"
//      user     = var.username
//      password = var.pwd
//      host     = element(azurerm_public_ip.common[*].ip_address, count.index)
//    }
//  }

}