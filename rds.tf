# Creating a DB subnet group with subnets in different AZs
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-private-subnet-group"
  #subnet_ids = aws_subnet.private_subnet[*].id
  subnet_ids = [
    aws_subnet.private_subnet[0].id,
    aws_subnet.private_subnet[2].id 
  ]
}

# RDS Aurora PostgreSQL cluster
resource "aws_rds_cluster" "coderDaBaCluster" {
  cluster_identifier           = var.dbc_coder_cluster_identifier
  database_name                = "coderrds"
  port                         = var.dbc_coder_port
  engine                       = var.dbc_coder_engine
  engine_version               = var.dbc_coder_engine_version
  storage_encrypted            = var.dbc_coder_storage_encrypted
  availability_zones           = ["eu-north-1a", "eu-north-1b"]
  apply_immediately            = true  # Can result in downtime as the server reboots
  deletion_protection          = false # Change to true in prod
  master_username              = var.db_username
  master_password              = var.db_password
  backup_retention_period      = var.dbc_coder_backup_ret_per
  preferred_backup_window      = var.dbc_coder_backup_window
  preferred_maintenance_window = var.dbc_coder_main_window
  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids       = [aws_security_group.rds_sg.id, aws_security_group.coder_aa.id]
  skip_final_snapshot          = true

  lifecycle {
    ignore_changes = [
      engine_version,
      availability_zones
    ]
  }
}

#Database isntance
resource "aws_rds_cluster_instance" "coderDB" {
  identifier                    = "auroradbcoderinstance"
  publicly_accessible           = false
  cluster_identifier            = aws_rds_cluster.coderDaBaCluster.id
  instance_class                = var.db_coder_instance_class
  db_subnet_group_name          = aws_db_subnet_group.db_subnet_group.id
  apply_immediately             = true # Can result in downtime as the server reboots
  engine                        = var.dbc_coder_engine
  engine_version                = var.dbc_coder_engine_version
  preferred_maintenance_window  = var.dbc_coder_main_window
}


# OUTPUTS #

output "db_instance_identifier" {
  value = aws_rds_cluster_instance.coderDB.id
}

output "db_instance_address" {
  value = aws_rds_cluster_instance.coderDB.endpoint
}
