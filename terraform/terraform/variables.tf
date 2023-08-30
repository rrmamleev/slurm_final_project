variable "k8s_version" {
  type    = number
}

variable "hosts_number" {
  type    = number
}

variable "platform_id" {
  type    = string
}

variable "resources" {
    type = object({
      cores  = number
      memory = number
      disk = number
    })
    description = "K8s node VM resources"
}

variable "az" {
    type        = list(string)
    description = "List of yandex availability zones."
}

variable "v4_cidr_blocks" {
    type        = list(list(string))
    description = "List of CIDRs"
}

# yandex

variable "YC_TOKEN" {
  type = string
}

variable "YC_CLOUD_ID" {
  type = string
}

variable "YC_FOLDER_ID" {
  type = string
}

# SSH

variable "SSH_USER" {
  type = string
}

variable "SSH_OPEN_KEY" {
  type = string
}

# DB

variable "DB_NAME" {
  type = string
}

variable "DB_USER" {
  type = string
}

variable "DB_PASS" {
  type = string
}

#dns

variable "YELB_APP_DNS_NAME" {
  type = string
}
