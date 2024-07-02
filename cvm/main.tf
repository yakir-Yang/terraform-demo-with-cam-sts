// Create VPC resource
resource "tencentcloud_vpc" "atlantis_terraform" {
  cidr_block = "10.0.0.0/16"
  name       = "atlantis_terraform_vpc"
  is_multicast      = false
}

resource "tencentcloud_subnet" "atlantis_terraform" {
  vpc_id            = tencentcloud_vpc.atlantis_terraform.id
  availability_zone = "ap-jakarta-2"
  name              = "atlantis_terraform_subnet"
  cidr_block        = "10.0.1.0/24"
  is_multicast      = false
}

// Create a POSTPAID_BY_HOUR CVM instance
resource "tencentcloud_instance" "cvm_atlantis_terraform" {
  instance_name     = "cvm_atlantis_terraform"
  availability_zone = "ap-jakarta-2"
  image_id          = "img-9qrfy1xt"
  instance_type     = "S5.MEDIUM2"
  system_disk_type  = "CLOUD_PREMIUM"
  system_disk_size  = 50
  hostname          = "user"
  project_id        = 0
  vpc_id            = tencentcloud_vpc.atlantis_terraform.id
  subnet_id         = tencentcloud_subnet.atlantis_terraform.id

  data_disks {
    data_disk_type = "CLOUD_PREMIUM"
    data_disk_size = 50
    encrypt        = false
  }
}
