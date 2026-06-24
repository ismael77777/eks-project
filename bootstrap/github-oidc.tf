# GitHub Actions OIDC trust: lets the CI/Apply workflows authenticate to AWS
# with short-lived tokens instead of stored credentials. Lives in bootstrap/
# because it is account-level setup that should persist independently of the
# cluster being created or destroyed.

# The GitHub OIDC identity provider.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

locals {
  github_org  = "ismael77777"
  github_repo = "eks-project"

  # Tightly scoped: only PRs (for the CI plan) and the production environment
  # (for the manually-approved apply) may assume the role. Deliberately NOT
  # repo:org/repo:* which would allow any branch.
  allowed_subjects = [
    "repo:${local.github_org}/${local.github_repo}:pull_request",
    "repo:${local.github_org}/${local.github_repo}:environment:production",
  ]
}

# The role GitHub Actions assumes.
resource "aws_iam_role" "github_actions" {
  name        = "github-actions-eks-project"
  description = "Assumed by GitHub Actions in ismael77777/eks-project via OIDC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.allowed_subjects
          }
        }
      }
    ]
  })
}

# Permissions. AdministratorAccess is pragmatic-but-blunt for a learning repo;
# a hardening follow-up would scope this to least privilege.
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_role_arn" {
  description = "Use as both AWS_PLAN_ROLE_ARN and AWS_APPLY_ROLE_ARN in GitHub"
  value       = aws_iam_role.github_actions.arn
}