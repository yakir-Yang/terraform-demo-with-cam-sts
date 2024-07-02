output "instance_id" {
  value = tencentcloud_instance.my_instance[0].id
}

output "public_ip" {
  value = tencentcloud_instance.my_instance[0].public_ip
}

