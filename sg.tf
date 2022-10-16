#Creating security group for vpc 
resource "aws_security_group" "slack_sg" {
  vpc_id      = aws_vpc.slack_vpc.id
  name        = "slack-sg"
  description = "Sec Grp for slack ssh"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  tags = {
    Name = "allow-ssh"
  }
}