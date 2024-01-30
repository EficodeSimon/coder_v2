# EFS
resource "aws_efs_file_system" "efs" {
  creation_token   = "coderefs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name = "EFS"
  }
}

# Create mount target for subnet in az1
resource "aws_efs_mount_target" "coder-efs-mt-az1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet[1].id
  security_groups = [aws_security_group.efs_security_group.id]
}

# Create mount target for subnet in az2
resource "aws_efs_mount_target" "coder-efs-mt-az2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet[3].id
  security_groups = [aws_security_group.efs_security_group.id]
}
