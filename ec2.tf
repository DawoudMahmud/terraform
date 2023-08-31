resource "aws_security_group" "main" {
  name        = "main"  
  description = "Allow SSH traffic"
  
  # allow all egress ("out") traffic out to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.main.id
}

resource "aws_key_pair" "dawouds_ssh_key" {
  key_name   = "dawouds_ssh_key"
  public_key = file("~/.ssh/id_ed25519.pub")  # this path ~/.ssh/id_rsa.pub should point to a real file on your local/laptop
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  availability_zone   = "us-east-1a"
  key_name = aws_key_pair.dawouds_ssh_key.key_name
  subnet_id = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.main.id]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
