output "service-dns" {
  value = module.service.dns_name
}

output "db-address" {
  value = module.db.db_instance_address
}

output "cache-address" {
  value = module.cache.redis_instance_address
}
