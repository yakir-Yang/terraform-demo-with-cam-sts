// Create VPC resource
resource "tencentcloud_vpc" "cicd_kk" {
  cidr_block = "10.0.0.0/16"
  name       = "cicd_kk_vpc"
  is_multicast      = false
}

resource "tencentcloud_subnet" "cicd_kk" {
  vpc_id            = tencentcloud_vpc.cicd_kk.id
  availability_zone = "ap-jakarta-2"
  name              = "cicd_kk_subnet"
  cidr_block        = "10.0.1.0/24"
  is_multicast      = false
}

// Create a POSTPAID_BY_HOUR CVM instance
resource "tencentcloud_instance" "cvm_cicd_kk_1" {
  instance_name     = "cvm_cicd_kk_1"
  availability_zone = "ap-jakarta-2"
  image_id          = "img-9qrfy1xt"
  instance_type     = "S5.MEDIUM2"
  system_disk_type  = "CLOUD_PREMIUM"
  system_disk_size  = 50
  hostname          = "user"
  project_id        = 0
  vpc_id            = tencentcloud_vpc.cicd_kk.id
  subnet_id         = tencentcloud_subnet.cicd_kk.id

  data_disks {
    data_disk_type = "CLOUD_PREMIUM"
    data_disk_size = 50
    encrypt        = false
  }
}
