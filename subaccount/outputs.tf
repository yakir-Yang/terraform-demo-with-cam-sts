output "sp_01_sa_id" {
  value = tencentcloud_cam_user.sp_01_sa.id
}

output "sp_01_sa_secret_access_key" {
  value = tencentcloud_cam_access_key.sp_01_sa_key.secret_access_key
  sensitive = true
}
