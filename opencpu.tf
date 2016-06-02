// OpenCPU

// ----- Primary availability zone

resource "aws_instance" "opencpu-a" {
    count = "${var.opencpu_node_count}"

    ami           = "${lookup(var.aws_deb_amis, var.aws_region)}"
    instance_type = "${var.opencpu_node_type}"
    key_name      = "${var.opencpu_node_boostrap_key_name}"

    vpc_security_group_ids = [
        "${var.opencpu_ssh_sg}",
        "${var.opencpu_http_sg}",
        "${var.opencpu_db_access_sg}"
    ]
    subnet_id = "${var.opencpu_primary_subnet_id}"

    tags {
        Name        = "opencpu-a-n${count.index + 1}.${var.opencpu_subdomain_name}"
        Purpose     = "OpenCPU Worker"
        Environment = "${var.opencpu_environment}"
        PHI         = "${lookup(var.opencpu_contains_phi, var.opencpu_environment)}"
        Origin      = "Terraform"
        Module      = "OpenCPU"
        Contact     = "${var.opencpu_contact}"
    }
}

resource "aws_route53_record" "opencpu-a-IN_A" {
    count = "${var.opencpu_node_count}"

    zone_id = "${var.opencpu_subdomain_zone_id}"
    name    = "opencpu-${var.opencpu_environment}-a-n${count.index + 1}"
    ttl     = 1
    type    = "A"
    records = ["${element(aws_instance.opencpu-a.*.private_ip, count.index)}"]
}

// ----- Redundant availability zone

resource "aws_instance" "opencpu-b" {
    count = "${var.opencpu_node_count}"

    ami           = "${lookup(var.aws_deb_amis, var.aws_region)}"
    instance_type = "${var.opencpu_node_type}"
    key_name      = "${var.opencpu_node_boostrap_key_name}"

    vpc_security_group_ids = [
        "${var.opencpu_ssh_sg}",
        "${var.opencpu_http_sg}",
        "${var.opencpu_db_access_sg}"
    ]
    subnet_id = "${var.opencpu_redundant_subnet_id}"

    tags {
        Name        = "opencpu-b-n${count.index + 1}.${var.opencpu_subdomain_name}"
        Purpose     = "OpenCPU Worker"
        Environment = "${var.opencpu_environment}"
        PHI         = "${lookup(var.opencpu_contains_phi, var.opencpu_environment)}"
        Origin      = "Terraform"
        Module      = "OpenCPU"
        Contact     = "${var.opencpu_contact}"
    }
}

resource "aws_route53_record" "opencpu-b-IN_A" {
    count = "${var.opencpu_node_count}"

    zone_id = "${var.opencpu_subdomain_zone_id}"
    name    = "opencpu-${var.opencpu_environment}-b-n${count.index + 1}"
    ttl     = 1
    type    = "A"
    records = ["${element(aws_instance.opencpu-b.*.private_ip, count.index)}"]
}

// ----- Clustering

resource "aws_elb" "opencpu" {
    name                      = "opencpu-${var.opencpu_environment}"
    internal                  = true
    cross_zone_load_balancing = true

    security_groups = ["${var.opencpu_http_sg}"]
    subnets         = ["${var.opencpu_primary_subnet_id}", "${var.opencpu_redundant_subnet_id}"]

    listener {

        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }
    listener {
        instance_port      = 443
        instance_protocol  = "https"
        lb_port            = 443
        lb_protocol        = "https"
        ssl_certificate_id = "${var.opencpu_elb_certificate_arn}"
    }

    health_check {
        health_threshold    = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTPS:443/"
        interval            = 15
    }

    instances = ["${aws_instance.opencpu-a.*.id}", "${aws_instance.opencpu-b.*.id}"]

    tags {
        Name        = "opencpu-${var.opencpu_environment}.${var.opencpu_subdomain_name}"
        Purpose     = "OpenCPU Load Balancer"
        Environment = "${var.opencpu_environment}"
        PHI         = "${lookup(var.opencpu_contains_phi, var.opencpu_environment)}"
        Origin      = "Terraform"
        Module      = "OpenCPU"
        Contact     = "${var.opencpu_contact}"
    }
}

resource "aws_route53_record" "opencpu-CNAME" {
    zone_id = "${var.opencpu_domain_zone_id}"
    name    = "opencpu-${var.opencpu_environment}"
    ttl     = 1
    type    = "CNAME"
    records = ["${aws_elb.opencpu.dns_name}"]
}

