# AWS IAM User and Group Creation with Terraform

## Intro

This Terraform project is designed to easily create a list of IAM groups with specific IAM policies, create IAM users and assign them to the previously created groups.

## Usage

-   Follow the [Configuration](#configuration) steps
-   Initialize Terraform

```hcl
terraform init
```

-   Verify

```hcl
terraform plan -var-file=users.tfvars
```

-   Build

```hcl
terraform apply -var-file=users.tfvars
```

-   Check the output and take note of the created users and password. Share with your users.

## Key Characteristics

-   Allows you to create a list of AWS users according to a Terraform variables file.
-   Creates an AWS group with a custom IAM policy defined in a JSON file.
-   You can create multiple `.tfvars` files for different groups and users.
-   IAM password policy configuration and enforcement.
-   Securely generates the user passwords using PGP for encrypting the values and not storing them as plaintext in state file
-   Created users are forced to change their password the first time they access
-   Base IAM policy applied to the group for allowing users to change their password and MFA device management
-   Modularized AWS IAM user and group management

## Usage Requirements

-   AWS credentials with the proper permissions for IAM management
-   Terraform installed

## Configuration

-   Clone the repo
-   Copy the file `providers.tf.template` as `providers.tf`. Configure with the desired region and (optionally) with the AWS profile to use.
-   Copy the file `users.tfvars.template` as `users.tfvars`. Check [Variable configuration](#variable-configuration).
-   Create the IAM policy you'll apply to the group the users will belong to. Store it in `/iam-policies/` folder as JSON file.

### Variable configuration

-   Set the list of usernames to create. Example:

```hcl
users = ["user1", "user2"]
```

-   Configure the IAM group the users will belong to. Example:

```hcl
team = "developers"
```

-   Define the path where you stored your IAM policy. Example:

```hcl
policy_file_path    = "./iam-policies/developers-policy.json"
```

-   If you want to apply a password policy for the AWS account, define the variable as follows:

```hcl
set_password_policy = true
```

## IAM Password Policy

In file `main.tf` it's configured a customizable password policy. Adjust according to your needs. If you don't want to use it, do not define the variable `set_password_policy`.

```hcl
resource "aws_iam_account_password_policy" "strict" {
  count                          = var.set_password_policy ? 1 : 0
  minimum_password_length        = 20
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}
```

## Terraform Providers Reference

-   [AWS] (https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
-   [PGP](https://registry.terraform.io/providers/ekristen/pgp/latest/docs)
