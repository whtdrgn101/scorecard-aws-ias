resource "aws_key_pair" "sc-key-pair" {
  key_name   = "sc-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "sc-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "sc-key-pair"
}

resource "aws_security_group" "sc_admin_sg" {
  name   = "${var.environment} SSH"
  vpc_id = aws_vpc.sc_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "scorecard_admin_server" {
  ami           = "ami-00a9282ce3b5ddfb1"
  instance_type = "t2.micro"
  key_name = "sc-key-pair"
  subnet_id = aws_subnet.sc_public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.sc_admin_sg.id]
  associate_public_ip_address = true
  
  tags = {
    Name = "ScorecardAdminServer"
  }
}