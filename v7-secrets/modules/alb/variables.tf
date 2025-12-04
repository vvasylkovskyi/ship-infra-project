variable "subnets" { type = list(string) }
variable "vpc_id" { type = string }
variable "acm_certificate_cert_arn" { type = string }
variable "acm_certificate_cert" {
  type = object({
    arn = string
    id  = string
  })
}
variable "ec2_instance_ids" { 
  type        = list(string)
  description = "List of EC2 instance IDs to attach to the target group"
}       
