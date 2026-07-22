locals {
  deployment_paused        = !var.api.enabled
  api_ingress_enabled      = !local.deployment_paused
  web_distribution_enabled = !local.deployment_paused
}

locals {
  public_subnet_cidrs = {
    for index, az in slice(data.aws_availability_zones.available.names, 0, 2) :
    az => cidrsubnet(var.vpc_cidr, 8, index)
  }

  private_subnet_cidrs = {
    for index, az in slice(data.aws_availability_zones.available.names, 0, 2) :
    az => cidrsubnet(var.vpc_cidr, 8, index + 10)
  }
}
