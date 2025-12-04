provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["./.aws-credentials"]
  profile                  = "terraform"
}

module "network" {
  source            = "./modules/network"
  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = var.availability_zone
}

module "ec2_first_instance" {
  source            = "./modules/ec2"
  instance_ami      = var.instance_ami
  instance_type     = var.instance_type
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  ssh_public_key    = var.ssh_public_key
  ssh_key_name    = "ec2-key-first-instance"
  security_group_name = "first-ec2-instance"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker

              # Add user to docker group
              sudo usermod -aG docker $USERNAME

              sudo docker run -d -p 80:80 \
              -e MY_API_KEY=${module.secrets.secrets.my_api_key} \
              nginx
              EOF
}

module "ec2_second_instance" {
  source            = "./modules/ec2"
  instance_ami      = var.instance_ami
  instance_type     = var.instance_type
  vpc_id = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[1]
  ssh_public_key    = var.ssh_public_key # Note, you can use the same public key for both instances, but not recommended for production
  ssh_key_name    = "ec2-key-second-instance"
  security_group_name = "second-ec2-instance"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker

              # Add user to docker group
              sudo usermod -aG docker $USERNAME

              sudo docker run -d -p 80:80 \
              -e MY_API_KEY=${module.secrets.secrets.my_api_key} \
              nginx
              EOF
}

resource "aws_route53_zone" "main" {
  name = "viktorvasylkovskyi.com"
}

module "ssl_acm" {
  source              = "./modules/acm"
  aws_route53_zone_id = aws_route53_zone.main.zone_id
}

module "alb" {
  source                  = "./modules/alb"
  subnets                 = module.network.public_subnet_ids
  vpc_id                  = module.network.vpc_id
  acm_certificate_cert_arn     = module.ssl_acm.aws_acm_certificate_arn
  acm_certificate_cert = module.ssl_acm.aws_acm_certificate_cert
  ec2_instance_ids        = [
    module.ec2_first_instance.instance_id,
    module.ec2_second_instance.instance_id
  ]
}

module "aws_route53_record" {
  source       = "./modules/dns"
  main_zone_id = aws_route53_zone.main.zone_id
  target_domain_name = module.alb.dns_name
  hosted_zone_id = module.alb.zone_id
}

module "secrets" {
  source           = "./modules/secrets"
  credentials_name = "my_app/v1/credentials"
}
