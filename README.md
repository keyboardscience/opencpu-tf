## OpenCPU Terraform Module

### Intro

A terraform module that standups up an OpenCPU cluster.

Creates two groups of worker nodes (where N-nodes is equal to `var.opencpu_node_count`; total is 2N) that are joined to an elastic load balancer.

#### Architecture

![](https://raw.githubusercontent.com/keyboardscience/opencpu-tf/master/docs/opencpu-tf-sys-arch.gif)

### Usage

```
// OpenCPU cluster (staging)

module "opencpu_staging" {
  source = "github.com/keyboardscience/opencpu-tf"

  // Initialization
  opencpu_node_boostrap_key_name = "example_key_name"

  // Networking

  // --- Subnets
  opencpu_primary_subnet_id = "${var.natA}"
  opencpu_redundant_subnet_id = "${var.natB}"

  // --- Security Groups
  opencpu_ssh_sg = "${var.default_sg}"
  opencpu_db_access_sg  = "${var.postgres_consumers_sg}"
  opencpu_http_sg  = "${var.pubhttps_sg}"

  // Clustering
  opencpu_elb_certificate_arn = "${var.omadahealth_net_certificate_arn}"

  // DNS
  opencpu_domain_name = "omadahealth.net"
  opencpu_domain_zone_id = "${var.apex_zone_id}"
  opencpu_subdomain_name = "west2.omadahealth.net"
  opencpu_subdomain_zone_id = "${var.west2_zone_id}"

  // Tagging
  opencpu_environment = "staging"
  opencpu_contact = "data-staging+opencpu@omadahealth.com"
}
```

### Contributing

Feel free to fork and create a pull request to get code/documentation merged. Help with issues and bug tracking would also be appreciated.

#### Issue Tracking

No `+1`s or other nonsense. We're trying to get background of a problem from the issue description, not guage the community's desire to get a fix.
