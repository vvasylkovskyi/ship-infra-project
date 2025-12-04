
resource "aws_security_group" "rds_sg" {
    name        = "rds_sg"
    description = "Allow Postgres access"
    vpc_id      = var.vpc_id
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
    }
        
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = [for id in var.subnet_ids : id]
  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier         = "postgres-db"
  engine             = "postgres"
  engine_version     = "15"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  storage_type       = "gp2"
  skip_final_snapshot    = true # for dev; not recommended in production
  username           = var.database_username
  password           = var.database_password
  db_name            = var.database_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible = true
}