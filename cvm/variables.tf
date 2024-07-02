variable "secret_id" {
  description = "The Secret ID for Tencent Cloud API"
  type        = IKID9i38xZw61g8MN9zhheNr66rQmCXguERd
}

variable "secret_key" {
  description = "The Secret Key for Tencent Cloud API"
  type        = 7ze9RULg6i7Zt3DEzby5xZv3FG6iAPTN
}

variable "region" {
  description = "The region where the instance will be created"
  type        = string
  default     = "ap-guangzhou"
}

variable "instance_name" {
  description = "The name of the CVM instance"
  type        = string
  default     = "terraform-altantis-with-aksk-instances"
}

variable "instance_type" {
  description = "The type of the CVM instance"
  type        = string
  default     = "S2.SMALL1"
}

variable "image_id" {
  description = "The ID of the image to use for the instance"
  type        = string
  default     = "img-9qrfy1xt" # TencentOS Server 3.2 (Final)
}

