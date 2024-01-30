# Configure the AWS Provider
# Region is specified in variables.tf 
# Profile is the name of the profile to use in .aws/credentials-file (mac) or C:\Users\<user>\.aws\credentials (windows)
provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

#Fetches the latest Coder AMI from Amazon Marketplace
data "aws_ami" "amzn2-coder" {
  filter {
    name   = "image-id"
    values = ["ami-0e3fa3dd314304716"]
  }
}


#Launch template for launching new instances
resource "aws_launch_template" "coder-launch-template" {
  name_prefix = "coder-launch-template"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.coder_instance_profile.name
  }

  image_id               = data.aws_ami.amzn2-coder.id
  instance_type          = var.lt_instance_type
  key_name               = var.keyname
  vpc_security_group_ids = ["${aws_security_group.coder_ec2_security_group.id}", "${aws_security_group.coder_aa.id}"]

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.tpl",
    {
      efs_dns_name = "${aws_efs_file_system.efs.dns_name}"
      rds_endpoint = "${aws_rds_cluster_instance.coderDB.endpoint}"
      db_username  = "${var.db_username}"
      db_password  = "${var.db_password}"
      web_url      = "http://${aws_lb.coder_nlb.dns_name}"
    }
  ))
}


# Create Auto Scaling Group
resource "aws_autoscaling_group" "coder-ASG" {
  name                = "coder_asg_tf"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 0
  force_delete        = true
  depends_on          = [aws_lb.coder_nlb]
  target_group_arns   = ["${aws_lb_target_group.coder_target_group.arn}"]
  health_check_type   = "EC2"
  vpc_zone_identifier = aws_subnet.public_subnet[*].id

  launch_template {
    id      = aws_launch_template.coder-launch-template.id
    version = "$Latest"
  }
  ##Kika på uppgraderingsalternativ
  tag {
    key                 = "Name"
    value               = "coder-asg"
    propagate_at_launch = true
  }
}





############# OUTPUTS #############
#=================================#
# You can see your outputs in the terminal you did a terraform apply in

#Outputs AMI ID
output "specific_ami_id" {
  value = data.aws_ami.amzn2-coder.id
}

#Outputs AMI Name
output "specific_ami_name" {
  value = data.aws_ami.amzn2-coder.name
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.coder_vpc.id
}

# Output the public and private subnets id
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}
