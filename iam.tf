
# IAM Role policy
# Using SSM for ease-of-use
resource "aws_iam_role" "coder_ec2_role" {
  name               = "coderEC2Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Instance profile
resource "aws_iam_instance_profile" "coder_instance_profile" {
  name = "coderEC2InstanceProfile"
  role = aws_iam_role.coder_ec2_role.name
}

# IAM policy for EC2 and SSM access
resource "aws_iam_role_policy_attachment" "coder_ec2_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.coder_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.coder_ec2_role.name
}