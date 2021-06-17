# Pesimistic ~> opoerator allows only 0.14.x, current max version supported by ORM
# https://www.terraform.io/docs/language/expressions/version-constraints.html

terraform {
 required_version = "~> 0.14.0"
 required_providers {
     # Recommendation from ORM / OCI provider teams
          oci = {
             version =">= 4.21.0"
          }
 }
}
