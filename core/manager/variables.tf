variable "name" {
  type = string
}

variable "count_managers" {
  type = string
}

variable "username" {
  type = string
}

variable "pwd" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "availability_set_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "storage_type" {}

variable "tags" {
  type = map
}

variable "ssh_key" {}

variable "ssh_port" {
  default = 22
}

variable "vm_size" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "image_offer" {
  type = string
}

variable "image_publisher" {
  type = string
}