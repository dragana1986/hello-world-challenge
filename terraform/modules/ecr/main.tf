resource "aws_ecr_repository" "this" {
  name                 = var.repository_name             # hint: repository_name
  image_tag_mutability = "MUTABLE"             # tags can be overwritten (fine for the challenge)

  image_scanning_configuration {
    scan_on_push = true                      # hint: true — auto CVE scan (best practice)
  }
}