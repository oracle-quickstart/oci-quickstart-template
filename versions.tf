#Version Syntax MAYOR.MINOR.PATH,  with a Min version ~<MAYOR.MINOR.0 (zero) and a Max tested version MAYOR.MINOR

terraform {
 required_version = "~> 0.14.0, < 0.15"
 required_providers {
     # Recommendation from ORM / OCI provider teams
          oci = {
             version ="~> 4.21.0"
          }
 }
} 
