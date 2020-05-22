variable "username" {
  default = "noname"
}

variable "product_name" {
  default = "noname"
}

variable "count_managers" {
  default = 1
}

variable "count_workers" {
  default = 0
}

variable "tag" {
  default = "noname"
}

variable "vm_size" {
  default     = "Standard_A3"
}

variable "location" {
  default = "West Europe"
}

variable "image_sku" {
  default     = "18.04-LTS"
}

variable "image_offer" {
  default     = "UbuntuServer"
}

variable "image_publisher" {
  default     = "Canonical"
}

variable "ssh_port" {
  default = "22"
}

variable "ssh_key" {
  type = string
}

variable "storage_type" {
  default = "Standard_LRS"
}
