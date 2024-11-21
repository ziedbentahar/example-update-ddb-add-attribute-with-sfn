data "aws_dynamodb_table" "table_to_update" {
  name = var.table_to_update.name
}