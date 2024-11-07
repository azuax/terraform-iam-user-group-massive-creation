variable "user_list" {
  type = list(string)
}

variable "team_name" {
  type = string
}

resource "pgp_key" "user_pgp" {
  count   = length(var.user_list)
  name    = var.user_list[count.index]
  email   = "${var.user_list[count.index]}@theemail.com"
  comment = var.user_list[count.index]
}


resource "aws_iam_user" "iam_user" {
  count = length(var.user_list)
  name  = var.user_list[count.index]
  tags = {
    team = var.team_name
  }
}

resource "aws_iam_user_login_profile" "console_access" {
  count                   = length(var.user_list)
  user                    = var.user_list[count.index]
  pgp_key                 = pgp_key.user_pgp[count.index].public_key_base64
  password_reset_required = true
  depends_on              = [aws_iam_user.iam_user, pgp_key.user_pgp]
}

data "pgp_decrypt" "user_pgp" {
  count               = length(var.user_list)
  private_key         = pgp_key.user_pgp[count.index].private_key
  ciphertext          = aws_iam_user_login_profile.console_access[count.index].encrypted_password
  ciphertext_encoding = "base64"
}

output "users" {
  value = aws_iam_user.iam_user.*.name
}

output "password_users" {
  value     = data.pgp_decrypt.user_pgp.*.plaintext
  sensitive = true
}
