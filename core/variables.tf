variable "username" {
  default = "dhomich"
}

variable "product_name" {
  default = "altdata2"
}

variable "vm_size" {
  description = "VMs size"
  default     = "Standard_A3"
}

variable "location" {
  default = "West Europe"
}

variable "image_sku" {
  description = "image sku (az vm image list)"
  default     = "18.04-LTS"
}

variable "image_offer" {
  description = "Server type (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_publisher" {
  description = "Publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "ssh_port" {
  default = "22"
}

variable "ssh_key" {
  type = "string"
}

variable "storage_type" {
  default = "Standard_LRS"
}