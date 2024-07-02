output "instance_id" {
  value = tencentcloud_instance.this[0].id
}

output "public_ip" {
  value = tencentcloud_instance.this[0].public_ip
}

