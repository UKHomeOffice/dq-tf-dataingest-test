variable "appsvpc_id" {
  default = "vpc-05554dda98b880e72"
}
variable "opssubnet_cidr_block" {
  default = "10.8.0.0/16"
}
variable "data_pipe_apps_cidr_block" {
  default = "10.1.8.0/24" 
}
variable "data_ingest_cidr_block" {
  default = "10.1.6.0/24"
}
variable "data_ingest_rds_cidr_block" {
  default = "10.1.7.0/24"
}
variable "peering_cidr_block" {
  default = "10.3.0.0/16"
}
variable "az" {
  default = "eu-west-2a"
}
variable "az2" {
  default = "eu-west-2b"
}
variable "logging_bucket_id" {
  default = "dq-tf-apps"
}
variable "archive_bucket" {
  default = "arn:aws:s3:::s3-dq-data-archive-bucket-test"
}
variable "archive_bucket_name" {
  default = "s3-dq-data-archive-bucket-test"
}
variable "apps_buckets_kms_key" {
  default = "arn:aws:kms:eu-west-2:797728447925:key/ad7169c4-6d6a-4d21-84ee-a3b54f4bef87"}

#variable "dq_database_cidr_block_secondary" {
#  type = "list"
#}

variable "naming_suffix" {
  default     = "apps-test-dq" 
}

variable "route_table_id" {
  default     = "rtb-001d05553d09aad32" 
  description = "Value obtained from Apps module"
}

variable "di_connectivity_tester_db_ip" {
  description = "Mock EC2 database instance."
  default     = "10.1.6.11"
}

variable "di_connectivity_tester_web_ip" {
  description = "Mock EC2 web instance."
  default     = "10.1.6.21"
}

variable "key_name" {
  default     = "test_instance"
  description = "Key name for login."
}

variable "key_name_linux" {
  default     = "test_instance"
  description = "Key name for login."
}

variable "dp_web_private_ip" {
  default     = "10.1.6.100"
  description = "Web server address"
}

variable "dp_web_linux_private_ip" {
  default     = "10.1.6.200"
  description = "Web server address"
}

variable "dq_lambda_subnet_cidr" {
  default     = "10.1.42.0/24"
}

variable "dq_lambda_subnet_cidr_az2" {
  default     = "10.1.43.0/24"
}
