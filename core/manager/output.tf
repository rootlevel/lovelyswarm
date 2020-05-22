output "manager_ips" {
  value = azurerm_public_ip.common.*.ip_address
}

output "manager_username" {
  value = var.username
}

output "manager_passwd" {
  value = var.pwd
}