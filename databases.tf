
resource "aws_security_group" "sc_database_sg" {
    name        = "${var.environment} PostgreSQL"
    vpc_id = aws_vpc.sc_vpc.id

    description = "Allow VPC inbound for Postgres from public subnet"
    
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = var.public_subnet_cidrs
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "sc_db_subnet_group" {
  name       = "${var.database_subnet_group_name}"
  subnet_ids = aws_subnet.sc_private_subnets[*].id

  tags = {
    Name = "${var.environment} DB subnet group"
  }
}

resource "aws_db_instance" "sc_db" {
  identifier             = "scorecard-db"
  db_name                = "scorecard_db"
  db_subnet_group_name   = "${var.database_subnet_group_name}"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.sc_database_sg.id]
  username               = "scorecard"
  password               = "App123!les"
}