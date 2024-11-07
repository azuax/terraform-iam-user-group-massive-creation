variable "group" {
  type = string
}

variable "users" {
  type = list(string)
}

resource "aws_iam_group" "group" {
  name = var.group
}

resource "aws_iam_group_membership" "group_user" {
  name       = "${var.group}_membership"
  users      = var.users
  group      = aws_iam_group.group.name
  depends_on = [aws_iam_group.group]
}

output "group_name" {
  value = aws_iam_group.group.name
}
