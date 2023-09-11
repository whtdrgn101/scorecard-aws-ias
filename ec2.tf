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
  
  user_data = <<EOF
    #!/bin/bash
    echo "#SCORECARD CONFIG" >> ~/.bashrc
    echo "export SCORECARD_USER=scorecard" >> ~/.bashrc
    echo "export SCORECARD_PASS=${random_password.sc_random_db_pass.result}" >> ~/.bashrc
    echo "export SCORECARD_HOST=${module.database.scorecard_database_hostname}" >> ~/.bashrc
    echo "export SCORECARD_DB=scorecard_db" >> ~/.bashrc
    sudo yum install git -y
    /usr/bin/git clone https://github.com/whtdrgn101/scorecard-db.git
    cd scorecard-db
    /usr/bin/python3 -v venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    python build_db.py
  EOF
  
  tags = {
    Name = "ScorecardAdminServer"
  }
}