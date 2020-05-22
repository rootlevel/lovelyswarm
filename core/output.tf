output "manager_ips" {
  value = "${join("\t", module.manager.manager_ips)}"
}

output "manager_username" {
  value = module.manager.manager_username
}

output "manager_passwd" {
  value = module.manager.manager_passwd
}

output "worker_ips" {
  value = "${join("\t", module.worker.worker_ips)}"
}

output "worker_username" {
  value = module.worker.worker_username
}

output "worker_passwd" {
  value = module.worker.worker_passwd
}