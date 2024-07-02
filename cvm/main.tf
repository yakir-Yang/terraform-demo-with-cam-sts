resource "tencentcloud_instance" {
  count         = 1
  instance_name = var.instance_name
  instance_type = var.instance_type
  image_id      = var.image_id
  system_disk {
    disk_type = "CLOUD_PREMIUM"
    disk_size = 50
  }
  internet_access {
    internet_charge_type = "TRAFFIC_POSTPAID_BY_HOUR"
    internet_max_bandwidth_out = 100
    public_ip_assigned = true
  }
}

