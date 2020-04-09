output "myips" {
  value = azurerm_public_ip.common.*.id
}