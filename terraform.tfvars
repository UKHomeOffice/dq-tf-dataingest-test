terragrunt = {
  remote_state {
    backend = "s3"
    config {
      bucket = "dacc-dq-test-coral-team"
      region = "eu-west-2"
      dynamodb_table = "terraform-state"
      key = "${get_env("TF_VAR_NAMESPACE", "notprod")}/dataingest-terraform.tfstate"
      encrypt = true
    }
  }
}
