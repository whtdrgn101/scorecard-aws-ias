provider "aws" {
  region  = "${var.region}"
}

module "database" {
    source = "./modules/databases"

    vpc_id = aws_vpc.sc_vpc.id
    environment = var.environment
    database_subnet_group_name = var.database_subnet_group_name
    public_subnet_cidrs = var.public_subnet_cidrs
    database_password = random_password.sc_random_db_pass.result
    database_user = "scorecard"
    private_subnet_ids = aws_subnet.sc_private_subnets[*].id
}