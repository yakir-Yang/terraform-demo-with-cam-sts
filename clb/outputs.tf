output "cvm1_instance_id" {
  value = tencentcloud_instance.cicd_foo_1.id
}

output "cvm2_instance_id" {
  value = tencentcloud_instance.cicd_foo_2.id
}

output "clb_instance_id" {
  value = tencentcloud_clb_instance.cicd_foo.id
}

