# 1. 创建子用户
resource "tencentcloud_cam_user" "sp_01_sa" {
  name   = "sp_01_sub_account"
  remark = "This is SP-01's sub account which created by Terraform"
  console_login = true
  use_api       = true
}

# 2. 为子用户创建 SecretID / SecretKey
resource "tencentcloud_cam_access_key" "sp_01_sa_key" {
  target_uin = tencentcloud_cam_user.sp_01_sa.uin
}

# 3. 创建 CAM Policy
resource "tencentcloud_cam_policy" "sp_01_policy" {
  name        = "sp_01_policy"
  description = "SP-01's custom policy created by Terraform"
  document    = <<EOF
{
    "version": "2.0",
    "statement": [
        {
            "effect": "allow",
            "action": ["*"],
            "resource": ["*"],
            "condition": {
                "for_any_value:string_equal": {
                    "qcs:request_tag": [
                        "application_level&gotocompany.com/GOJEK/EndPlatform/INT/SP-01"
                    ]
                }
            }
        },
        {
            "effect": "allow",
            "action": ["*"],
            "resource": ["*"],
            "condition": {
                "for_any_value:string_equal": {
                    "qcs:resource_tag": [
                        "application_level&gotocompany.com/GOJEK/EndPlatform/INT/SP-01"
                    ]
                }
            }
        }
    ]
}
EOF
}

# 4. 绑定 CAM Policy 到子用户
resource "tencentcloud_cam_user_policy_attachment" "user_policy_attach" {
  user_name   = tencentcloud_cam_user.sp_01_sa.name
  policy_id = tencentcloud_cam_policy.sp_01_policy.id
}
