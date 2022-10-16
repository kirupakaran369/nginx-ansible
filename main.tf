
# Creating instances with our slack_vpc
resource "aws_key_pair" "key_pair" {
  key_name   = "key_pair"
  public_key = file(var.pub_key_path)
}

resource "aws_instance" "slack-IaC" {
  ami                    = var.ami[var.region]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.slack-pub-1.id
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.slack_sg.id]
  user_data              = file("nginx-setup.yml")
  tags = {
    Name = "Slack-IaC"
  }
}

#Adding extra volume
resource "aws_ebs_volume" "vol_4_slack" {
  availability_zone = var.zone1
  size              = 3
  tags = {
    Name = "extr-vol-4-slack"
  }
}

# Attaching extra volume
resource "aws_volume_attachment" "atch_vol_dove" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.vol_4_slack.id
  instance_id = aws_instance.slack-IaC.id
}

data "aws_instance" "slack-IaC-data" {
  filter {
    name   = "tag:Name"
    values = ["Slack-IaC"]
  }
  depends_on = [
    aws_instance.slack-IaC
  ]
}

output "Public_ip" {
  value = data.aws_instance.slack-IaC-data.public_ip
}