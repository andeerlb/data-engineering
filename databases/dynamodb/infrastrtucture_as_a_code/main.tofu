resource "aws_dynamodb_table" "users" {
  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Environment = "local"
  }
}

resource "aws_dynamodb_table" "orders" {
  name         = "orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"
  range_key    = "created_at"

  attribute {
    name = "order_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  # LSI
  local_secondary_index {
    name            = "status-index"
    range_key       = "status"
    projection_type = "ALL"
  }

  # GSI #1
  global_secondary_index {
    name            = "user_id-created_at-index"
    hash_key        = "user_id"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # GSI #2
  global_secondary_index {
    name            = "status-created_at-index"
    hash_key        = "status"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  stream_enabled   = true
  # Defines what data is written to the stream on each change (INSERT/MODIFY/REMOVE):
  #   KEYS_ONLY        — only the primary key of the changed item
  #   NEW_IMAGE        — the entire item after the change
  #   OLD_IMAGE        — the entire item before the change
  #   NEW_AND_OLD_IMAGES — full item state before and after (useful for CDC/auditing)
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Environment = "local"
  }
}
