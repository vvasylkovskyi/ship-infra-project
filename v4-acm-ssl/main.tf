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

module "ec2" {
  source            = "./modules/ec2"
  instance_ami      = var.instance_ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  subnet_id         = module.network.subnet_id
  ssh_public_key    = var.ssh_public_key
  vpc_id            = module.network.vpc_id
}

resource "aws_route53_zone" "main" {
  name = "viktorvasylkovskyi.com"
}

module "aws_route53_record" {
  source       = "./modules/dns"
  domain_name  = "www.viktorvasylkovskyi.com"
  dns_record   = module.ec2.public_ip
  main_zone_id = aws_route53_zone.main.zone_id
}

module "ssl_acm" {
  source              = "./modules/acm"
  aws_route53_zone_id = aws_route53_zone.main.zone_id
}