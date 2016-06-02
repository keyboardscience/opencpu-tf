// Scale -

variable "opencpu_node_count" {
    default = 1
}

variable "opencpu_node_type" {
    default = "c4.large"
}

// Module scaffold -

// Mandatory arguments

variable "opencpu_primary_subnet_id" {}
variable "opencpu_redundant_subnet_id" {}
variable "opencpu_node_boostrap_key_name" {}
variable "opencpu_ssh_sg" {}
variable "opencpu_db_access_sg" {}
variable "opencpu_http_sg" {}
variable "opencpu_elb_certificate_arn" {}
variable "opencpu_domain_zone_id" {}
variable "opencpu_subdomain_zone_id" {}

// Provided defaults
variable "opencpu_environment" {
    default = "test"
}

variable "opencpu_contains_phi" {
    default = {
        "test"        = false
        "staging"     = true
        "production"  = true
    }
}

variable "opencpu_contact" {
    default = "platform+opencpu@opencpu.local"
}

variable "opencpu_subdomain_name" {
    default = "internal.opencpu.local"
}

variable "opencpu_domain_name" {
    default = "opencpu.local"
}

variable "aws_deb_amis" {
    default = {
      // TODO change this ...
        us-west-2 = "ami-98e114f8"
        us-east-1 = "ami-c8bda8a2"
        eu-west-1 = "ami-e079f893"
    }
}

variable "aws_region" {
  default = "us-west-2"
}
