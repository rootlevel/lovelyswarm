variable "username" {
  default = "defimova"
}

variable "product_name" {
  default = "lrepo"
}

variable "count_managers" {
  default = 0
}

variable "count_workers" {
  default = 0
}

variable "tag" {
  default = ""
}

variable "vm_size" {
  default     = "Standard_A3"
}

variable "location" {
  default = "West Europe"
}

variable "image_sku" {
  default     = "7.5"
}

variable "image_offer" {
  default     = "CentOS"
}

variable "image_publisher" {
  default     = "OpenLogic"
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