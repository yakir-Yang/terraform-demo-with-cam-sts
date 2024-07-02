resource "tencentcloud_security_group" "cicd_foo" {
  name = "cicd-foo-sg"
}

resource "tencentcloud_vpc" "cicd_foo" {
  name       = "cicd-foo-vpc"
  cidr_block = "10.0.0.0/16"
  is_multicast      = false
}

resource "tencentcloud_subnet" "cicd_foo" {
  availability_zone = var.availability_zone
  name              = "cicd-foo-subnet"
  vpc_id            = tencentcloud_vpc.cicd_foo.id
  cidr_block        = "10.0.0.0/16"
  is_multicast      = false
}

resource "tencentcloud_instance" "cicd_foo_1" {
  instance_name              = "cicd_foo_cvm1"
  availability_zone          = var.availability_zone
  image_id                   = "img-9qrfy1xt"
  instance_type              = "S5.MEDIUM2"
  system_disk_type           = "CLOUD_PREMIUM"
  internet_max_bandwidth_out = 0
  vpc_id                     = tencentcloud_vpc.cicd_foo.id
  subnet_id                  = tencentcloud_subnet.cicd_foo.id
}

resource "tencentcloud_instance" "cicd_foo_2" {
  instance_name              = "cicd_foo_cvm2"
  availability_zone          = var.availability_zone
  image_id                   = "img-9qrfy1xt"
  instance_type              = "S5.MEDIUM2"
  system_disk_type           = "CLOUD_PREMIUM"
  internet_max_bandwidth_out = 0
  vpc_id                     = tencentcloud_vpc.cicd_foo.id
  subnet_id                  = tencentcloud_subnet.cicd_foo.id
}

resource "tencentcloud_clb_instance" "cicd_foo" {
  clb_name                  = "cicd_foo_clb"
  network_type              = "OPEN"
  #network_forward           = "CLASSIC"
  project_id                = 0
  vpc_id                    = tencentcloud_vpc.cicd_foo.id
  #target_region_info_region = "ap-guangzhou"
  #target_region_info_vpc_id = tencentcloud_vpc.cicd_foo.id
  security_groups           = [tencentcloud_security_group.cicd_foo.id]
}

resource "tencentcloud_clb_listener" "listener_tcp" {
  clb_id                     = tencentcloud_clb_instance.cicd_foo.id
  listener_name              = "listener_tcp"
  port                       = 8080
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 30
  health_check_interval_time = 100
  health_check_health_num    = 2
  health_check_unhealth_num  = 2
  session_expire_time        = 30
  scheduler                  = "WRR"
  health_check_port          = 200
  health_check_type          = "HTTP"
  health_check_http_code     = 2
  health_check_http_version  = "HTTP/1.0"
  health_check_http_method   = "GET"
}

resource "tencentcloud_clb_attachment" "attachment_tcp" {
  clb_id      = tencentcloud_clb_instance.cicd_foo.id
  listener_id = tencentcloud_clb_listener.listener_tcp.listener_id

  targets {
    instance_id = tencentcloud_instance.cicd_foo_1.id
    port        = 8080
    weight      = 10
  }

  targets {
    instance_id = tencentcloud_instance.cicd_foo_2.id
    port        = 8080
    weight      = 10
  }
}

resource "tencentcloud_clb_listener" "listener_http_src" {
  clb_id        = tencentcloud_clb_instance.cicd_foo.id
  port          = 80
  protocol      = "HTTP"
  listener_name = "listener_http_src"
}

resource "tencentcloud_clb_listener_rule" "rule_http_src" {
  clb_id              = tencentcloud_clb_instance.cicd_foo.id
  listener_id         = tencentcloud_clb_listener.listener_http_src.listener_id
  domain              = "abc.com"
  url                 = "/"
  session_expire_time = 30
  scheduler           = "WRR"
}

resource "tencentcloud_clb_listener" "listener_http_dst" {
  clb_id        = tencentcloud_clb_instance.cicd_foo.id
  port          = 81
  protocol      = "HTTP"
  listener_name = "listener_http_dst"
}

resource "tencentcloud_clb_listener_rule" "rule_http_dst" {
  clb_id              = tencentcloud_clb_instance.cicd_foo.id
  listener_id         = tencentcloud_clb_listener.listener_http_dst.listener_id
  domain              = "abcd.com"
  url                 = "/"
  session_expire_time = 30
  scheduler           = "WRR"
}

resource "tencentcloud_clb_redirection" "redirection_http" {
  clb_id             = tencentcloud_clb_instance.cicd_foo.id
  source_listener_id = tencentcloud_clb_listener.listener_http_src.listener_id
  target_listener_id = tencentcloud_clb_listener.listener_http_dst.listener_id
  source_rule_id     = tencentcloud_clb_listener_rule.rule_http_src.rule_id
  target_rule_id     = tencentcloud_clb_listener_rule.rule_http_dst.rule_id
}
