# GitHub Actions OIDC Integration

# Check if OIDC provider already exists to prevent duplication error, but since we are doing standard IaC:
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# In case it doesn't exist, we can use the data source or provision it.
# To make it robust and idempotent, we'll provision the provider if not registered,
# but using a data source is safer if we ran the helper script. Let's make sure it imports/references it.
# Let's create the IAM role.
resource "aws_iam_role" "github_actions" {
  name = "calmroot-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_username}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "calmroot-github-actions-role"
  }
}

resource "aws_iam_role_policy_attachment" "github_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
