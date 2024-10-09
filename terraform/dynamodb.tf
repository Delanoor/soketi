resource "aws_dynamodb_table" "soketi_apps" {
  name           = "soketi-apps"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "AppId"

  attribute {
    name = "AppId"
    type = "S"
  }

  attribute {
    name = "AppKey"
    type = "S"
  }

  global_secondary_index {
    name               = "AppKeyIndex"
    hash_key           = "AppKey"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }
}
