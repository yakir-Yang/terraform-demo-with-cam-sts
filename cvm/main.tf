resource "tencentcloud_instance" "my_instance" {
  instance_name = "example"
  availability_zone = "ap-guangzhou-3"
  instance_type = "S3.MEDIUM4"
  image_id = "img-9qrfy1xt" # TencentOS Server 3.2 (Final)
  system_disk_type = "CLOUD_BASIC"
  system_disk_size = "50"
  internet_charge_type = "BANDWIDTH_PREPAID"
  internet_max_bandwidth_out = "10"

  lifecycle {
    ignore_changes = [internet_max_bandwidth_out]
  }
}
