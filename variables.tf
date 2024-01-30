

#AWS Profile (Must have valid credentials)
variable "profile" {
  description = "AWS profile used for deployment"
  default     = "coder"
}

#Launch verified docker ami (eu-north-1)
#This is a marketplace ami pre-configured with docker to ease the implementation
#This is region-specific, if region changes from eu-north-1, then ami needs to change aswell
variable "ami" {
  type = string

  #Official Coder V2 AMI for eu-north-1, if you want another region you need to specify that specific regions Coder V2 ami
  default = "ami-0e3fa3dd314304716"
}

# Define availability zones
variable "az" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

#AWS region
variable "aws_region" {
  description = "AWS region to use"
  default     = "eu-north-1"
}

#Key stored in key pairs, used for launch templates. Change this to a Key Pair in your environment
variable "keyname" {
  default = "coderkp"
}

# Isntance type for the launch template. This will be your Coder Server. Might be a good idea to use a bigger instance if 
# the demand increases.
variable "lt_instance_type" {
  description = "The instance type to use when launching new EC2"
  default     = "t3.xlarge"
}

#Database username and password
#It's a good idea to keep these in AWS Secrets Manager and fecth them on apply in production
#For testing purposes it's fine to use these
variable "db_username" {
  default = "coderadmin"
}
variable "db_password" {
  default = "Kenneth1234"
}

#The url for the coder server. For now it's the load balancer. Later on you want this to be a DNS in Route53 (e.g. https://coder.example.com)
variable "web_url" {
  description = "URL for CODER_ACCESS_URL"
  default     = "example.com"
}




#Database cluster settings

# Database identifier
variable "dbc_coder_cluster_identifier" {
  type    = string
  default = "dbc-coder"
}

# Database engine to use. Coder uses postgresql
variable "dbc_coder_engine" {
  type    = string
  default = "aurora-postgresql"
}

#Database version. min. 13 for coder
variable "dbc_coder_engine_version" {
  type    = string
  default = "14.3"
}

#Database port
variable "dbc_coder_port" {
  type    = string
  default = "5432"
}

#Database encrytion settings
variable "dbc_coder_storage_encrypted" {
  type    = string
  default = "true"
}

#Database retention period. This is the amount of days that RDS will automate backups.
#In this case RDS will delete all backups older than 21 days
variable "dbc_coder_backup_ret_per" {
  default = 21
}

#Database Backup Window. What time to do the backups.
variable "dbc_coder_backup_window" {
  type    = string
  default = "01:00-02:00"
}

#Database maintenance window
variable "dbc_coder_main_window" {
  type    = string
  default = "sat:04:00-sat:04:30"
}

#Database instance settings. What configuration your database instance will have.
variable "db_coder_instance_class" {
  type    = string
  default = "db.r5.xlarge"
}
