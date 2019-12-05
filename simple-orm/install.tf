
data "archive_file" "generate_zip" {
  type        = "zip"
  output_path = "${path.module}/dist/orm.zip"
  source_dir = "../simple-cli"
  excludes    = ["terraform.tfstate", "terraform.tfvars.template", "provider.tf"]
}