output "worker_ips" {
  value = azurerm_public_ip.common.*.ip_address
}

output "worker_username" {
  value = var.username
}

output "worker_passwd" {
  value = var.pwd
}



