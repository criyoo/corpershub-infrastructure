data "aws_route53_zone" "main" {
  provider = aws.root

  name         = "corpershub.ng"
  private_zone = false
}


# resource "aws_route53_zone" "main" {
#   provider = aws.root

#   name = "corpershub.ng"
#private_zone = false
#   tags = {
#     Environment = "root"
#   }
# }
