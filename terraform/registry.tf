resource "aws_ecr_repository" "backend" {
  name                 = "nexacart-backend"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "frontend" {
  name                 = "nexacart-frontend"
  image_tag_mutability = "MUTABLE"
}