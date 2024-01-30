# Security group for EC2 instances
resource "aws_security_group" "coder_ec2_security_group" {
  name        = "CoderEC2SecurityGroup"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.coder_vpc.id

  # Ingress rule allowing traffic from ALB on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    #security_groups = [aws_security_group.nlb_security_group.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    description = "HTTP"
    #security_groups = [aws_security_group.nlb_security_group.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"
    #security_groups = [aws_security_group.nlb_security_group.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

      ingress {
    from_port   = 13337
    to_port     = 13337
    protocol    = "tcp"
    description = "Code Server"
    #security_groups = [aws_security_group.nlb_security_group.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  # Add other ingress or egress rules as needed
}

# ========================= #
# RDS                       #

resource "aws_security_group" "rds_sg" {
  name        = "CoderRDSSecurityGroup"
  description = "RDS Server"
  vpc_id      = aws_vpc.coder_vpc.id
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.coder_ec2_security_group.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ========================= #
# Network Load Balancer     #

resource "aws_security_group" "nlb_security_group" {
  name        = "CoderNLBSecurityGroup"
  description = "Security group for NLB"
  vpc_id      = aws_vpc.coder_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}



# ========================= #
# EFS                       #

#Elastic File System (EFS) Security group
resource "aws_security_group" "efs_security_group" {
  name        = "Coder-EFS"
  description = "Allows inbound ssh EFS traffic from Coder"
  vpc_id      = aws_vpc.coder_vpc.id

  ingress {
    security_groups = [aws_security_group.coder_ec2_security_group.id]
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }

  egress {
    security_groups = [aws_security_group.coder_ec2_security_group.id]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
}


# ========================= #
#     Allows all            #

# Used for internal communication for your resoruces inside of AWS
resource "aws_security_group" "coder_aa" {
  name        = "coder-AA"
  description = "Allows all inbound traffic from Coder"
  vpc_id      = aws_vpc.coder_vpc.id

  ingress {
    security_groups = [aws_security_group.coder_ec2_security_group.id]
    from_port       = 0
    to_port         = 0
    protocol        = "all"
  }
}