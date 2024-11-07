variable "users" {
  type        = list(string)
  description = "List of users to create and associate with a group"
}

variable "team" {
  type        = string
  description = "Name of the team/group"
}

variable "policy_file_path" {
  type        = string
  description = "Decoupled JSON policy to manage the permissions for groups"
}

variable "set_password_policy" {
  type        = bool
  description = "Apply a password policy for the AWS account"
  default     = false
}

# Setup Password policy
resource "aws_iam_account_password_policy" "strict" {
  count                          = var.set_password_policy ? 1 : 0
  minimum_password_length        = 20
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}



# User Creation with random password (will output)
module "iam_user" {
  source    = "./modules/iam-user"
  user_list = var.users
  team_name = var.team
}

module "iam_group" {
  source     = "./modules/iam-group"
  group      = var.team
  users      = module.iam_user.users
  depends_on = [module.iam_user]
}

# Base policy for allow change password and configure MFA
resource "aws_iam_policy" "base_policy" {
  name   = "base_policy"
  policy = file("./iam-policies/base-change-pwd-mfa.json")
}
resource "aws_iam_group_policy_attachment" "base_policy_attachment" {
  group      = module.iam_group.group_name
  policy_arn = aws_iam_policy.base_policy.arn
  depends_on = [aws_iam_policy.base_policy, module.iam_group]
}

# Specific group policy
resource "aws_iam_policy" "group_policy" {
  name   = "${var.team}_policy"
  policy = file(var.policy_file_path)
}
resource "aws_iam_group_policy_attachment" "group_policy_attachment" {
  group      = module.iam_group.group_name
  policy_arn = aws_iam_policy.group_policy.arn
  depends_on = [aws_iam_policy.group_policy, module.iam_group]
}


output "users" {
  value = module.iam_user.users
}

output "passwords" {
  value = module.iam_user.password_users
}
