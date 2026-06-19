# Elastic Container Registry repository to hold the app's Docker image.
resource "aws_ecr_repository" "app" {
  name = "hello-eks"

  # Scan images for vulnerabilities automatically when pushed.
  image_scanning_configuration {
    scan_on_push = true
  }

  # IMMUTABLE tags prevent an existing tag (e.g. a release) from being
  # overwritten, which protects against silently changing what's deployed.
  image_tag_mutability = "IMMUTABLE"

  # Encrypt images at rest.
  encryption_configuration {
    encryption_type = "KMS"
  }
}

# Output the repository URL so it's easy to grab for docker push / manifests.
output "ecr_repository_url" {
  description = "URL of the ECR repository for the app image"
  value       = aws_ecr_repository.app.repository_url
}